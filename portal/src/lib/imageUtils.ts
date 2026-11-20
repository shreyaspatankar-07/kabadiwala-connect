/**
 * Client-side image compression using HTML5 Canvas (no extra dependencies).
 * Compresses a File/Blob to JPEG/WebP under maxKB using iterative quality reduction.
 * Falls back gracefully if Canvas API is unavailable.
 */

export async function compressImageToWebP(
  file: File,
  maxKB = 800,
  initialQuality = 0.85
): Promise<Blob> {
  return new Promise((resolve, reject) => {
    // If already small enough, skip compression
    if (file.size <= maxKB * 1024) {
      resolve(file);
      return;
    }

    const img = new Image();
    const objectUrl = URL.createObjectURL(file);

    img.onload = () => {
      URL.revokeObjectURL(objectUrl);

      const canvas = document.createElement("canvas");
      // Scale down if very large (> 1920 on longest side) to save memory on 2GB devices
      const maxDim = 1920;
      let { width, height } = img;
      if (width > maxDim || height > maxDim) {
        if (width > height) {
          height = Math.round((height * maxDim) / width);
          width = maxDim;
        } else {
          width = Math.round((width * maxDim) / height);
          height = maxDim;
        }
      }
      canvas.width = width;
      canvas.height = height;

      const ctx = canvas.getContext("2d");
      if (!ctx) {
        // Canvas unavailable — return original
        resolve(file);
        return;
      }
      ctx.drawImage(img, 0, 0, width, height);

      // Iteratively compress until under maxKB
      const tryQuality = (quality: number) => {
        canvas.toBlob(
          (blob) => {
            if (!blob) {
              resolve(file);
              return;
            }
            if (blob.size <= maxKB * 1024 || quality <= 0.3) {
              resolve(blob);
            } else {
              tryQuality(parseFloat((quality - 0.1).toFixed(1)));
            }
          },
          "image/webp",
          quality
        );
      };

      tryQuality(initialQuality);
    };

    img.onerror = () => {
      URL.revokeObjectURL(objectUrl);
      reject(new Error("Failed to load image for compression"));
    };

    img.src = objectUrl;
  });
}

/**
 * Uploads a compressed Blob directly to Supabase Storage bucket `scrap-photos`
 * using the anonymous/public upload REST API (no SDK required).
 * Returns the permanent public CDN URL.
 */
export async function uploadScrapPhotoToSupabase(
  blob: Blob,
  filename: string
): Promise<string> {
  const supabaseUrl =
    process.env.NEXT_PUBLIC_SUPABASE_URL ||
    "https://dudxikzfszckgoxcbbhh.supabase.co";
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";

  const uploadPath = `pickups/${filename}`;
  const uploadUrl = `${supabaseUrl}/storage/v1/object/scrap-photos/${uploadPath}`;

  const res = await fetch(uploadUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${supabaseAnonKey}`,
      apikey: supabaseAnonKey,
      "Content-Type": blob.type || "image/webp",
      "x-upsert": "true",
    },
    body: blob,
  });

  if (!res.ok) {
    let detail = "";
    try {
      const json = await res.json();
      detail = json.message || json.error || "";
    } catch {}
    throw new Error(
      `Supabase upload failed (${res.status}): ${detail || res.statusText}`
    );
  }

  // Return public CDN URL
  return `${supabaseUrl}/storage/v1/object/public/scrap-photos/${uploadPath}`;
}
