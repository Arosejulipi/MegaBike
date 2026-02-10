(function () {
  function qs(root, sel) {
    return root.querySelector(sel);
  }

  async function uploadToCloudinary(opts) {
    const url = "https://api.cloudinary.com/v1_1/" + encodeURIComponent(opts.cloudName) + "/image/upload";
    const fd = new FormData();
    fd.append("file", opts.file);
    fd.append("upload_preset", opts.uploadPreset);
    if (opts.folder) fd.append("folder", opts.folder);

    const res = await fetch(url, { method: "POST", body: fd });
    const json = await res.json().catch(() => ({}));
    if (!res.ok) {
      const msg = (json && (json.error && json.error.message)) || ("HTTP " + res.status);
      throw new Error(msg);
    }
    return json;
  }

  function init() {
    const root = document.querySelector("[data-cloudinary-upload]");
    if (!root) return;

    const cloudName = root.dataset.cloudinaryCloudName || "";
    const uploadPreset = root.dataset.cloudinaryUploadPreset || "";
    const folder = root.dataset.cloudinaryFolder || "";

    const fileInput = qs(root, "[data-cloudinary-file]");
    const urlInput = qs(root, "[data-cloudinary-url], input[data-cloudinary-url]");
    const status = qs(root, "[data-cloudinary-status]");
    const preview = qs(root, "[data-cloudinary-preview]");

    if (!fileInput || !urlInput || !status) return;

    function setStatus(text, kind) {
      status.textContent = text || "";
      status.className = "form-text";
      if (kind === "error") status.className = "form-text text-danger";
      if (kind === "ok") status.className = "form-text text-success";
    }

    function setPreview(url) {
      if (!preview) return;
      if (!url) {
        preview.style.display = "none";
        preview.style.removeProperty("--mbk-img");
        return;
      }
      preview.style.display = "block";
      preview.style.setProperty("--mbk-img", "url('" + url.replaceAll("'", "%27") + "')");
    }

    fileInput.addEventListener("change", async () => {
      const file = fileInput.files && fileInput.files[0];
      if (!file) return;

      if (!cloudName || !uploadPreset) {
        setStatus("Falta configurar Cloudinary en Render (CLOUDINARY_CLOUD_NAME / CLOUDINARY_UPLOAD_PRESET).", "error");
        return;
      }

      setStatus("Subiendo imagen...", "");
      try {
        const json = await uploadToCloudinary({
          cloudName: cloudName,
          uploadPreset: uploadPreset,
          folder: folder,
          file: file
        });
        const secureUrl = (json && (json.secure_url || json.url)) || "";
        if (!secureUrl) throw new Error("No se recibio URL de Cloudinary.");

        urlInput.value = secureUrl;
        setPreview(secureUrl);
        setStatus("Listo. Imagen subida.", "ok");
      } catch (e) {
        setStatus("Error al subir: " + (e && e.message ? e.message : String(e)), "error");
      }
    });

    // If the form already has an URL, show it.
    setPreview(urlInput.value);
  }

  document.addEventListener("DOMContentLoaded", init);
})();
