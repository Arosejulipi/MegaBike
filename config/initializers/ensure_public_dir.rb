# frozen_string_literal: true

# Ensure `public` directory exists at runtime so debug middleware can write files.
begin
  public_dir = Rails.root.join('public')
  unless Dir.exist?(public_dir)
    FileUtils.mkdir_p(public_dir)
    Rails.logger.info "Created missing public directory: ", public_dir.to_s
  end
rescue => e
  Rails.logger.error "Failed to ensure public dir: #{e.class}: #{e.message}"
end
