# Binary Star

Binary Star is an explorative visual novel about relationships, made using Godot 4.
It follows Aneska and Yuvan and was migrated from the original Unity project.
The original Ink story, illustrations, animation frames, Exo 2 font, and audio
are reused. Gameplay is GDScript, and UnityEvents are replaced by native Godot
signals connected in the scene.

## Run

Open `project.godot` in **Godot 4.7 or newer** and press **F6** with
`scenes/main.tscn` open, or **F5** to run the project. Tested with Godot 4.7.2.
The standard Godot build is sufficient; Unity and .NET are not required.
The first import takes a little time to process the original artwork and audio.

```sh
godot --editor --path .
# Or run directly after import:
godot --path .
```

- Click, tap, Space, or Enter: reveal the current line, then advance.
- Choices: ↑/↓ or Tab to move the cursor, 1–9 to select, Enter or Space to confirm.
  Clicking or tapping a response chooses it directly. Home/End jump to either end.
- **Sound on/off** or **M**: mute or unmute.
- **Restart** / **Read again**: start the conversation over.

Portrait highlights fade in over 0.15 seconds while speaking and fade out over
0.25 seconds when the line finishes. Select either portrait in Godot to adjust
**Highlight Fade In** and **Highlight Fade Out**; zero makes that direction instant.

The speaker name sits below the current dialogue. When you advance, the actual
text moves from its reading position into the starfield over one second. The next
line begins typing once it clears that space. Older lines stay upright as they
shrink and fade over 24 seconds, starting gently to stay readable longer.
Click again during departure to finish the motion and reveal the next line.
Select **DialogueHistory** to adjust **Handoff Duration**, **Fade Duration**, or
**Maximum Entries**.

Choices appear in a navy terminal panel with numbered, monospaced responses and
a lavender selection cursor. Long responses wrap, and longer menus scroll to keep
the selected response visible. The panel uses bundled
[JetBrains Mono](Assets/Fonts%20%26%20Materials/JetBrainsMono/README.md).
Moving between responses plays a light keyboard thock; confirming plays a deeper,
weightier thock. Both follow the sound toggle. Select **Audio** to adjust **Choice Volume Db**.
The original cues in `Assets/SFX` can be regenerated with
`python3 tools/generate_ui_audio.py`.

Play as Yuvan through the late-night call, doctor referral, and relationship
conflict. Three or four opening choices lead into six more decisions through
the confrontation, with Aneska's cumulative empathy selecting one of three
resolutions. To jump directly to the first choice menu:

```sh
godot --path . --script tests/preview_choices.gd
```

This shortcut runs the same story as the main game. **Restart** and **Read again**
return to its opening line. Choosing a character at startup is still planned;
the current choices are Yuvan's.

## Project layout

| Path | Purpose |
| --- | --- |
| `scenes/main.tscn` | Playable scene, editable UI, and serialized signal connections |
| `scenes/dialogue_choices.tscn` | Terminal choice panel, typography, and colors |
| `scripts/` | Story, dialogue presentation, frame animation, and audio controllers |
| `data/*.tres` | Native SpriteFrames converted from Unity's character/background databases |
| `Assets/Ink/BinaryStar.ink` | Shared conversation, original scenes, and return points |
| `Assets/Ink/Opening.ink` | Authored Yuvan choices, Aneska's responses, and scoring calls |
| `Assets/Ink/Conflict.ink` | Six conflict decisions, climax, final tally, and three resolutions |
| `Assets/Ink/BinaryStar.json` | Compiled Ink story, loaded by the game |
| `Assets/Ink/Empathy.ink` | Shared tone matrix and cumulative empathy scoring |
| `Assets/Data`, `Assets/MUSIC`, `Assets/Fonts & Materials` | Original media used directly by Godot |
| `addons/inkgd` | Vendored pure GDScript Ink runtime with its MIT license and pinned provenance |
| `tests/` | Scene integration tests and source-derived reference transcripts |
| `tools/convert_unity_data.py` | Reproducible conversion of Unity's sprite GUID references |
| `tools/generate_ui_audio.py` | Reproducible synthesis of the choice navigation and confirmation cues |

Unity scenes, C# packages, and settings are retained for reference and excluded
from Godot scanning/export. New development starts in `project.godot`.
See [migration notes and UnityEvent → signal mapping](docs/MIGRATION.md).

## Story editing

Edit the `.ink` file, then compile it back to `Assets/Ink/BinaryStar.json` with
[Inky or inklecate](https://github.com/inkle/ink). Keep both files together in
version control. The bundled runtime supports Ink JSON versions 18 through 21.
The restored story is compiled with official **inklecate 1.2.1** to format 21,
matching the runtime. A compiler is only needed when editing the story, not to
run the game:

```sh
inklecate -o Assets/Ink/BinaryStar.json Assets/Ink/BinaryStar.ink
```

The playable opening has **63 possible routes**. Accepting the astronaut topic joins at the original K-pop
joke. The support routes rejoin at "I just really miss you", either directly or
after the shared fear-and-reassurance exchange. Returning from that exchange
resumes the pending astronaut topic. The later argument calls back to their
earlier conversation and remembers whether Aneska has already explained being
tired, so she only explains it once. Six later decisions carry the argument
through a sustained climax. The storm starts after the birthday dispute exposes
both characters' fears, stays through two more decisions, and settles after the
ending's first exchange. Nine or ten choices per playthrough yield 45,927 full
choice histories. The original `BRANCH2` and `OUTRO` remain available as reference
knots and are exercised separately in tests.

The two tags on a dialogue line are character name and emotion, for example
`#Aneska #HAPPY`. `InitiateStorm()` and `EndStorm()` emit phase signals for the
visuals and music. `ChangeBackground("Planet", "Day")` is also bound for future
story use. See `story_controller.gd` for the signal API.

Both star backgrounds animate through their 17 `2_Storm_*` frames at 4 fps when
the storm starts, then play those frames in reverse when it ends. Recovery then
crossfades for one second back to the original calm artwork, restoring its size
and orientation instead of holding the padded first storm frame. The separate
eight-frame `Breakdown/3_Storm_*` sets remain unused, as in the Unity scene.

Aneska's empathy is an Ink integer, `aneska_empathy`, starting at **0 (neutral)**
on each playthrough. `Empathy.ink` defines the approved matrix (rows: Aneska's
prompt; columns: Yuvan's response):

| Prompt / Response | Warm | Vulnerable | Frustrated |
| --- | --- | --- | --- |
| Warm | +1 | 0 | -1 |
| Vulnerable | +1 | 0 | -1 |
| Frustrated | 0 | +1 | -1 |

Include that file and call the shared scorer inside each selected choice branch:

```ink
* [yeah it is quite late now, and I'm not feeling that great]
    ~ ScoreEmpathy(TONE_FRUSTRATED, TONE_VULNERABLE)
    // Yuvan's line and Aneska's response follow here.
```

Use the authored prompt tone; the example above adds one point. Choosing a row
applies its score once. Merely displaying choices, reading, or revealing a line
does not score empathy. Later Ink conditions can read the accumulated value to
choose a resolution. The current narrative and working prompt tones are recorded
in [the story workshop](docs/STORY_WORKSHOP.md). The main game scores each
opening choice. The first three prompts currently use warm; the impatient
follow-ups before the fourth use frustrated. These working tone assignments are
documented in the workshop and can be adjusted separately from the matrix.
The six later prompts use vulnerable, frustrated, vulnerable, frustrated,
vulnerable, and warm respectively. After the last choice, `final_empathy` selects
**A little closer** (5+), **Still reaching** (0–4), or **A quiet distance** (below 0).
These thresholds are initial playtest values; the full score range is -10 to +9.
Godot exposes the resulting `Story.ending_title` when the conversation ends, plus
`Story.aneska_empathy` and an `empathy_changed(value)` signal. There is no visible
meter. Portrait emotion tags and reading speed do not determine the score.
At completion, the dialogue fades away and a centered **Ending Unlocked** reveal
spotlights the title. **Read again** supports mouse and keyboard replay; restarting
during the reveal cancels the animation and restores the normal dialogue view.

## Verify

```sh
godot --headless --path . --editor --import
godot --headless --path . --script tests/run_tests.gd
# Optional: real rendering, input checks, and twenty-seven screenshots in test-results/
godot --path . --script tests/run_tests.gd -- --screenshots
```

Tests cover the authored opening and original alternate dialogue, storm events, music
crossfades, typewriter completion, portrait focus and interrupted fades,
speaker placement, receding dialogue history and cleanup, input,
repeat play, variable choice counts, choice keyboard/mouse/touch input, wrapped
and scrolling menus, sprite references, reverse background animation, calm recovery,
and all three ending reveals. They exit nonzero on failure.
Empathy fixtures check all nine tone combinations, scoring only committed
choices, persistence after branches rejoin, conditional follow-up dialogue,
the final tally, recovery, and reset between playthroughs. All 63 live story
routes preserve their authored words and tags and are played through the new
conflict. Every one of the 729 conflict-choice sequences is tested with varying
incoming scores and conversation state. Checks cover decision order, distinct
reactions, cumulative scoring, sustained storm pacing, all three resolutions,
threshold boundaries, and restart. The scene test plays all ten menus through
real keyboard input. The small opening fixture remains an isolated UI test.

After changing the scoring helper or a fixture's Ink, recompile its consumers:

```sh
inklecate -o Assets/Ink/BinaryStar.json Assets/Ink/BinaryStar.ink
inklecate -o tests/fixtures/empathy.json tests/fixtures/empathy.ink
inklecate -o tests/fixtures/choice_preview.json tests/fixtures/choice_preview.ink
```

Regenerate Godot sprite databases from the preserved Unity assets with Python 3:

```sh
python3 tools/convert_unity_data.py
```

After migration, the `.tres` files can also be edited directly in Godot. Running
the converter again overwrites them using the original Unity databases.

## Export

The **Web** preset and [GitHub Pages workflow](.github/workflows/deploy-pages.yml)
build an iframe-ready browser version. Pull requests validate it; pushes to
`main` publish the site after Pages is configured. See
[Web deployment and embedding](docs/WEB_DEPLOYMENT.md) for the one-time setup,
local preview, and copyable iframe snippet.

Desktop presets are included for macOS, Windows, and Linux. Install export
templates matching your Godot version through **Editor → Manage Export Templates**
before producing a standalone application. Platform signing/distribution setup
is not included.

```sh
mkdir -p builds
godot --headless --path . --export-release macOS builds/BinaryStar.zip
```

A game pack can be exported and run with the installed Godot executable without
export templates:

```sh
godot --headless --path . --export-pack macOS builds/BinaryStar.pck
godot --main-pack builds/BinaryStar.pck
```
## Licensing

This project is dual-licensed:

- The source code is available under the MIT license.
- Art assets (images) are [CC-By 4.0](https://creativecommons.org/licenses/by/4.0/). You can attribute them to [Floretta Eleora C](https://www.linkedin.com/in/floretta-eleora-c-63a3061b4).
