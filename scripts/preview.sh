#!/usr/bin/env bash
# Make a file visible in Multica, or refuse and say why.
#
# The platform previews four classes and nothing else (REFERENCE → attachments, measured
# 2026-08-01): images, PDF, HTML, and text-as-source. Everything else — video, audio, Office,
# archives, design files, unknown binaries — arrives as a download nobody opens. A rule that
# merely ASKS an agent to "render a preview" is the class of rule this project has twice
# measured as not holding, so this is a script that produces the rendition or exits non-zero
# with a named reason. Silence is the failure it removes.
#
# Usage:  bash scripts/preview.sh <file>
# Prints, in attach order, the paths to attach — the rendition first, the original last:
#     bash scripts/preview.sh deck.pptx | xargs -I{} echo --attachment {}
# Exit 0  = something previewable exists (possibly the file itself).
# Exit 3  = no rendition is possible here; the reason is on stderr. Say it in the comment
#           rather than attaching an opaque file and calling it done.
# Exit 2  = the renderer for this class is not installed; the install line is on stderr.
set -euo pipefail

f="${1:-}"
[ -n "$f" ] && [ -f "$f" ] || { echo "usage: preview.sh <file>" >&2; exit 64; }
ext="$(printf '%s' "${f##*.}" | tr '[:upper:]' '[:lower:]')"
base="${f%.*}"
say() { echo "preview.sh: $*" >&2; }

case "$ext" in
  # ── already previewable: the platform renders these itself ────────────────
  png|jpg|jpeg|gif|svg|webp|pdf|html|htm)
    say "$ext previews natively — attach as is"
    echo "$f"; exit 0 ;;

  # Text of any extension opens as SOURCE, which is readable but is not a picture.
  # Mermaid is the special case worth naming: the diagram renders when it is written in the
  # comment BODY inside a ```mermaid fence. Attaching the file only ever shows the source.
  mmd|mermaid)
    say "put this in the comment body inside a \`\`\`mermaid fence — it renders as a diagram there"
    say "attaching the file shows the source only; do both when the source must travel"
    echo "$f"; exit 0 ;;
  txt|md|csv|json|yaml|yml|rivet-project|log)
    say "$ext opens as source text — readable, not a picture"
    echo "$f"; exit 0 ;;

  # ── needs a rendition ─────────────────────────────────────────────────────
  docx|xlsx|pptx|doc|xls|ppt|pages|numbers|key|rtf)
    # Office files are ZIPs, so the platform types them application/zip and offers no preview
    # at all. macOS QuickLook renders the first page without installing anything.
    if command -v qlmanage >/dev/null 2>&1; then
      out="$(dirname "$f")"
      qlmanage -t -s 1600 -o "$out" "$f" >/dev/null 2>&1 || true
      [ -f "$f.png" ] && { echo "$f.png"; echo "$f"; exit 0; }
    fi
    say "no page render for $ext. QuickLook (macOS) or 'soffice --convert-to pdf' produces one"
    exit 2 ;;

  mp4|webm|mov|m4v|avi)
    # No player on the platform: a video is a file row. A poster frame answers "what is this",
    # a short looping GIF answers "what happens" — and a GIF does animate inline.
    command -v ffmpeg >/dev/null 2>&1 || { say "ffmpeg not installed — brew install ffmpeg"; exit 2; }
    ffmpeg -loglevel error -i "$f" -frames:v 1 -y "${base}-poster.png" </dev/null
    ffmpeg -loglevel error -i "$f" -vf "fps=8,scale=480:-1:flags=lanczos" -t 6 -y "${base}-preview.gif" </dev/null
    say "poster frame + a 6s looping GIF; both animate/render inline"
    echo "${base}-preview.gif"; echo "${base}-poster.png"; echo "$f"; exit 0 ;;

  pen|fig)
    # A .pen is JSON, so its frame list is readable with no tooling — but rendering needs
    # OpenPencil, and measured 2026-08-01 neither route is free: the MCP export needs the app
    # running ("failed to connect to running Pencil app"), and the CLI is Bun-only
    # (`npx @open-pencil/cli` dies with "Bun is not defined").
    if command -v openpencil >/dev/null 2>&1; then
      openpencil export "$f" -o "${base}.png" >/dev/null 2>&1 && { echo "${base}.png"; echo "$f"; exit 0; }
    fi
    say "no renderer for $ext. Either open it in the Pencil app and export via MCP, or"
    say "  bun add -g @open-pencil/cli   then   openpencil export $f --node <id> -o NN-<name>.png"
    say "the frame ids are plain JSON inside the file: .children[].id"
    exit 2 ;;

  riv)
    say "Rive has no headless renderer here — export a GIF or MP4 from the Rive editor and"
    say "attach that beside the .riv"
    exit 3 ;;

  mp3|wav|m4a|aac|flac)
    say "audio cannot be shown as a picture. Say in the comment what it is, how long it runs,"
    say "and what to listen for — an unlabelled audio file is an unopened one"
    exit 3 ;;

  zip|tar|gz|tgz|7z|rar|dmg|exe|bin)
    say "an archive or binary has nothing to preview. Name its contents in the comment"
    exit 3 ;;

  *)
    say "unknown type .$ext — the platform will treat it as a download."
    say "Render something a reader can see, or say plainly that there is nothing to look at"
    exit 3 ;;
esac
