(function () {
  const root = document.querySelector(".mbk-support");
  if (!root) return;

  const whatsappUrl = root.dataset.whatsappUrl || "";
  const aiEnabled = (root.dataset.aiEnabled || "1") === "1";
  const aiModel = root.dataset.aiModel || "";

  const fab = document.getElementById("mbkSupportFab");
  const panel = document.getElementById("mbkSupportPanel");
  const closeBtn = document.getElementById("mbkSupportClose");
  const chat = document.getElementById("mbkSupportChat");
  const msg = document.getElementById("mbkSupportMsg");
  const send = document.getElementById("mbkSupportSend");

  let greeted = false;
  let aiEngine = null;

  function escapeHtml(s) {
    return String(s)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;");
  }

  function addLine(who, htmlText) {
    const div = document.createElement("div");
    div.className = "mbk-support__line";
    div.innerHTML = `<span class="mbk-support__who">${escapeHtml(who)}:</span> <span>${htmlText}</span>`;
    chat.appendChild(div);
    chat.scrollTop = chat.scrollHeight;
  }

  function quickAnswer(q) {
    const t = (q || "").toLowerCase();
    if (t.includes("turno") || t.includes("service") || t.includes("servicio")) {
      return 'Podes agendar desde "Servicios". Completa el formulario y te llega confirmacion por mail.';
    }
    if (t.includes("horario") || t.includes("hora")) {
      return "Horarios de turnos: 08:30-13:30 y 16:00-19:00.";
    }
    if (t.includes("envio") || t.includes("envios") || t.includes("envíos")) {
      return "Si, hacemos envios. Te confirmamos costo y tiempos al comprar o por WhatsApp.";
    }
    if (t.includes("pago") || t.includes("tarjeta") || t.includes("transfer")) {
      return "Aceptamos efectivo, transferencia y tarjetas (segun disponibilidad).";
    }
    if (t.includes("personal") || t.includes("personalizada") || t.includes("presupuesto")) {
      return 'Entra a "Personalizado", completa el formulario y nos llega tu pedido por mail.';
    }
    return null;
  }

  function escalateAnswer() {
    if (!whatsappUrl) return "No encontre una respuesta rapida. Escribinos por WhatsApp.";
    return `No encontre una respuesta rapida. <a href="${whatsappUrl}" target="_blank" rel="noopener">Hablemos por WhatsApp</a>.`;
  }

  function ensureGreeted() {
    if (greeted) return;
    greeted = true;
    addLine("Soporte", "Hola! En que te ayudo?");
  }

  function open() {
    panel.hidden = false;
    panel.classList.add("is-open");
    msg && msg.focus();
    ensureGreeted();
  }

  function close() {
    panel.hidden = true;
    panel.classList.remove("is-open");
  }

  fab && fab.addEventListener("click", () => (panel.hidden ? open() : close()));
  closeBtn && closeBtn.addEventListener("click", close);

  async function initAI() {
    if (!aiEnabled) return null;
    if (aiEngine) return aiEngine;

    try {
      // WebLLM: runs in the client's browser (no API keys). If it fails, we fallback.
      const webllm = await import("https://esm.run/@mlc-ai/web-llm");

      // Model name can change across WebLLM versions; keep it configurable and fail-safe.
      const model =
        aiModel ||
        "Llama-3.2-1B-Instruct-q4f16_1-MLC";

      aiEngine = await webllm.CreateMLCEngine(model, {
        initProgressCallback: () => {},
      });
      return aiEngine;
    } catch (e) {
      return null;
    }
  }

  function shouldEscalateFromText(text) {
    const t = (text || "").toLowerCase();
    if (t.includes("escalar")) return true;
    if (t.includes("no se") || t.includes("no puedo") || t.includes("no estoy seguro")) return true;
    return false;
  }

  async function aiAnswer(q) {
    const engine = await initAI();
    if (!engine) return null;

    const system = [
      "Sos el asistente de soporte de Mega Bike (bicicleteria). Responde SIEMPRE en espanol.",
      "Horarios de turnos disponibles: 08:30-13:30 y 16:00-19:00.",
      'Para agendar, indicar: ir a "Servicios" y completar el formulario.',
      'Para bici personalizada: ir a "Personalizado" y completar el formulario.',
      "Si no estas seguro o no tenes datos, responde EXACTAMENTE: ESCALAR"
    ].join("\n");

    try {
      const res = await engine.chat.completions.create({
        messages: [
          { role: "system", content: system },
          { role: "user", content: q },
        ],
        temperature: 0.2,
        max_tokens: 220,
      });

      const text = (res && res.choices && res.choices[0] && res.choices[0].message && res.choices[0].message.content) || "";
      return String(text).trim();
    } catch (e) {
      return null;
    }
  }

  async function onSend() {
    const q = (msg.value || "").trim();
    if (!q) return;
    ensureGreeted();
    addLine("Vos", escapeHtml(q));
    msg.value = "";

    // 1) Quick deterministic answer
    const quick = quickAnswer(q);
    if (quick) {
      addLine("Soporte", escapeHtml(quick));
      return;
    }

    // 2) Optional "smart" attempt (runs in the user's browser)
    if (aiEnabled) {
      const ans = await aiAnswer(q);
      if (ans && !shouldEscalateFromText(ans)) {
        addLine("Soporte", escapeHtml(ans));
        return;
      }
    }

    // 3) Escalate to WhatsApp
    addLine("Soporte", escalateAnswer());
  }

  send && send.addEventListener("click", onSend);
  msg && msg.addEventListener("keydown", (e) => {
    if (e.key === "Enter") onSend();
  });
})();
