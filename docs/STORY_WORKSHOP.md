# Story workshop

Dialogue and routing from the authoring conversation. Yuvan's authored opening
is now playable in the main game, using `Assets/Ink/Opening.ink` and the approved
empathy matrix. The binary-star conversation continues after the opening branches rejoin.
`Assets/Ink/Conflict.ink` then carries six more choices through the confrontation
and three empathy-based resolutions. Aneska's first opening replies remain
working drafts; the user's authored opening dialogue keeps its wording.

## Perspective

Plan: offer Aneska or Yuvan at the beginning of a playthrough, with the player
choosing the selected character's replies. We are writing Yuvan's perspective
first. The current game plays as Yuvan; the perspective selector and Aneska's
playable route are still future work.

## Aneska's empathy

Author's direction: Yuvan's goal is to help Aneska empathize with him. Each
opening choice should receive a different response. Track Aneska's empathy
throughout the conversation, starting neutral; negative choices can reduce it.

The story now declares `aneska_empathy = 0`. Ink branches can raise or lower the
value, and later conditions can use it even after branches rejoin. Restarting
resets it. It is currently hidden, with no player-facing meter. The matrix is
approved and implemented. The current ending thresholds and dialogue are
playable drafts, described below.
Emotion tags and reading speed do not change empathy automatically.

### Approved tone matrix

Prompt means Aneska's tone; response means Yuvan's chosen tone. The author has
approved all nine values. The shared implementation is `Assets/Ink/Empathy.ink`:

| Aneska's prompt / Yuvan's response | Warm | Vulnerable | Frustrated |
| --- | --- | --- | --- |
| Warm | +1 | 0 | -1 |
| Vulnerable | +1 | 0 | -1 |
| Frustrated | 0 | +1 | -1 |

Warmth earns the most empathy when Aneska is warm or vulnerable;
vulnerability earns the most when she is frustrated. Frustrated responses reduce
empathy in every prompt state.

Each scored Ink choice calls `ScoreEmpathy(prompt_tone, response_tone)` once
inside its selected branch. Displaying choices, moving the cursor, reading text,
or revealing a line does not score points. Zero-point combinations leave the
value unchanged. This scoring is separate from portrait emotion tags.

### Final resolution

Author's direction: empathy is a cumulative point system. Apply the matrix's
change for each scored choice, carrying the total across the conversation. At
the final resolution, the accumulated score determines the story's ending.
Individual choices contribute to that total; the ending is selected at the end.
There is no requirement for every tone to be equally effective at earning empathy.

The matrix, score storage, and reset are connected to the main novel. The opening
has three choices on the direct binary-star route and four on the support routes,
for 63 possible opening routes. Six later decisions continue through the conflict,
for nine or ten total choices per playthrough. The final score is tallied only
after the last choice and selects one of three resolutions:

| Final empathy | Resolution | Story outcome |
| --- | --- | --- |
| 5 or higher | A little closer | Aneska asks about the appointment and offers concrete support; their humor returns. |
| 0 to 4 | Still reaching | They agree on a small next step without claiming everything is fixed. |
| Below 0 | A quiet distance | They pause a hurtful conversation with their relationship unresolved. |

The full reachable score range is -10 to +9. Thresholds are initial playtest
values in `Conflict.ink`, not permanent balancing decisions. The ending title is
shown after the last line; the numerical score remains hidden. Restart clears
the score, final tally, ending, and remembered conversation details.

### Working prompt tones in this playable pass

| Prompt | Tone | Warm / Vulnerable / Frustrated score |
| --- | --- | --- |
| "Oh my god, what time is it for you?" | Warm | +1 / 0 / -1 |
| "How are you, though?" / "Was today that bad?" | Warm | +1 / 0 / -1 |
| Reassurance followed by the astronaut topic change | Warm | +1 / 0 / -1 |
| "Oh—I thought you were done..." | Frustrated | 0 / +1 / -1 |
| "Okay, okay... quick" | Frustrated | 0 / +1 / -1 |

These are implementation defaults for playtesting, separate from the approved
matrix and from portrait emotion tags. They can be revised during authoring.
The current opening's reachable final empathy range is -4 to +3.

## Beat 1: The late-night call

Yuvan is anxious after a doctor's appointment. Their call was scheduled for
11 p.m.; it is now 2 a.m. for him when Aneska joins.

Aneska opens with the existing line:

> Oh my god, what time is it for you?

### Yuvan's opening choices

These are the user's selected words. Tone labels are authoring notes; the menu
will present the dialogue itself. Wording is preserved; portrait tags are assigned
in Ink for the playable pass.

| Tone | Dialogue |
| --- | --- |
| Warm | hi! don't worry about it - did you have a good day? |
| Vulnerable | yeah it is quite late now, and I'm not feeling that great |
| Frustrated | It is 2 am here… our call was supposed to be at 11 pm. Have you just arrived at your place? |

### Opening replies (working drafts)

Aneska's original response to the frustrated opening was:

> Yeah, I’m so sorry - how are you though?

The game uses these assistant drafts, shortened so the shared check-in below
does not repeat their questions. They remain open to the author's revision:

| Yuvan's choice | Aneska's proposed reply |
| --- | --- |
| Warm | Hi, sayang! It was a long day, but going out helped. |
| Vulnerable | Oh, Van… I’m sorry I wasn’t here. |
| Frustrated | Yeah, I just got home. I’m sorry I kept you waiting… I didn’t realise how late it was. |

The game treats Aneska's opening as warm, so the three responses score +1, 0,
and -1 respectively. Each reply then joins the shared check-in below, preserving
the accumulated score. Restart resets it to zero.

## Beat 2: Why Yuvan needed the call

Shared prompt after the opening branches: Aneska asks, warmly,
"How are you, though?" The accumulated empathy score carries into this beat.
After the vulnerable opening, she instead asks "Was today that bad?", since
Yuvan has already told her he is not feeling great. This connecting line is
working copy added after playtesting.

### Yuvan's choices

| Tone | Dialogue | Status | Empathy change for a warm prompt |
| --- | --- | --- | --- |
| Warm | It was pretty bad. But talking to you right now makes it better already. | Authored by the user | +1 |
| Vulnerable | I felt so... alone. Like nobody is on my side and helping me through things. | Authored by the user | 0 |
| Frustrated | you know.... it was bad, but you not being here on time makes it even worse | Authored by the user | -1 |

### Aneska's reactions

| Yuvan's choice | Aneska's reply | Status |
| --- | --- | --- |
| Warm | Awww, okay. | Authored by the user |
| Vulnerable | Right. | Authored by the user |
| Frustrated | Yeah, well, I was hanging out with my friends. | Authored by the user |

### Aneska's shared follow-up

After whichever immediate reaction applies, Aneska continues with the user's
authored line:

> So, what happened? what makes you feel that way?

These are two consecutive Aneska lines: her path-specific reaction, then this
shared question. Yuvan responds after the question. The accumulated empathy
score carries forward; Aneska's additional line does not score points.

### Yuvan's explanation

Yuvan answers Aneska's question with the user's authored line:

> I went to the Doctor, and ugh... he told me I should see the specialist just in case. He said it is probably nothing, but it is making me anxious

This establishes the doctor's appointment and uncertainty about the referral as
the reason for his anxiety. It is currently a shared story line; no choice
variants or empathy changes have been assigned to it.

### Aneska's reply and change of subject

Aneska responds with the user's authored line:

> I think it should be fine. Anyway, do you wanna know what I heard from my friend who is an Astronaut?

She briefly reassures Yuvan, then changes the subject to something she heard
from her astronaut friend. This NPC line does not change the empathy score;
the next choice uses warm as its working prompt tone.

### Yuvan's responses to the change of subject

All three options below were drafted by the assistant and approved by the user.

| Tone | Dialogue | Status |
| --- | --- | --- |
| Warm | An astronaut? Okay, you’ve got me curious. What did they say? | Approved by the user |
| Vulnerable | I do wanna hear it, but... can we stay with this for a little longer? I’m still feeling anxious. | Approved by the user |
| Frustrated | Seriously? I just told you what happened, and you’re already changing the subject? | Approved by the user |

These choices score +1, 0, and -1 respectively against the warm prompt.

### Warm path: return to the original binary-star conversation

The user directed Aneska to introduce binary stars and reconnect to the original
script, with the cue "So apparent.... binary starts". Working bridge wording,
expanded from that cue:

> Aneska: So apparently… there’s something called a binary star.

This replaces the original topic introduction, "I learned about Binary Star
today", at the shared `binary_star_intro` knot. Continue with the existing dialogue in
[BinaryStar.ink](../Assets/Ink/BinaryStar.ink), starting with Yuvan's K-pop joke:

> Yuvan: What’s that? A new K-Pop group? Like Big Bang?
>
> Aneska: Yes - from Nebula Entertainment. Their visuals are astronomical! Don’t even get me started on their GRAVITY
>
> Yuvan: Uhh - what…?
>
> Aneska: No - it is not a K-Pop Band.
>
> Yuvan: Oh, so what is it then?
>
> Aneska: So - they are stars, like our Sun - but instead of solo - they go abouts in duets.

The original binary-star conversation continues from there. This warm path joins
it directly, skipping the original missing-you, cuddle, and movie lead-in. The
support routes below retain those earlier exchanges. Carry the
accumulated empathy into the rejoined conversation without resetting or scoring
the join itself.

### Vulnerable path: Aneska's response

After Yuvan asks to stay with his anxiety a little longer, Aneska responds with
the user's authored line:

> Oh—I thought you were done. So what else do you want to talk about in regards to that?

The user confirmed the opening wording, "Oh—I thought you were done".

### Frustrated path: Aneska's response

After Yuvan challenges her change of subject, Aneska responds with the user's
authored line:

> Okay, okay. Just starts talking about it then... quick

All three immediate Aneska responses to the change-of-subject choices are now
recorded. The warm path returns to the original binary-star conversation; the
vulnerable and frustrated paths leave room for Yuvan to continue discussing his
anxiety. These NPC responses do not themselves change the empathy score.

### Shared choice after the vulnerable and frustrated paths

The user directed both paths to meet at a new Yuvan choice point after their
respective Aneska replies. The warm path still continues into the original
binary-star conversation. Preserve the accumulated empathy when the two paths
meet; joining them does not itself score points.

The user has authored all three options for this shared choice:

| Tone | Dialogue | Status |
| --- | --- | --- |
| Warm | Hey, what's wrong? I feel like you are being a bit harsh towards me. | Authored by the user |
| Vulnerable | I don't know. I'm just so anxious. It would make me feel better if you'd actually ask me follow up questions that makes me feel like you care about me | Authored by the user |
| Frustrated (provisional) | What.... You sound like you don't really want to know. | Authored by the user; tone proposed by the assistant |

The frustrated tone assignment is a working interpretation. Each incoming path
passes its preceding prompt tone into `ask_for_support(prompt_tone)`. Both
impatient replies currently use frustrated, so these choices score 0, +1, and -1
respectively. Their prompt tones can be edited independently in Ink.

### Aneska's responses at the shared choice

After Yuvan's warm option ("Hey, what's wrong? I feel like you are being a bit
harsh towards me."), Aneska responds with the user's authored line:

> Sigh. I'm just realy tired. And I really don't feel like talking right now

After Yuvan's vulnerable option, in which he asks her to show she cares by
asking follow-up questions, Aneska responds with the user's authored line:

> Sigh, okay. So what is it in particular making you feel anxious about this... whole deal?

After Yuvan's frustrated option ("What.... You sound like you don't really want
to know."), Aneska responds with the user's authored line:

> No, I do want to know. Come on, just say what you need to say.

All three Aneska replies at this choice point are now authored.

### Bringing the conversation back to the original script

The user asked to bring the conversation back and authored Yuvan's explanation:

> It is just you know.... what if it is something that is sinister.

Use this as a shared continuation after the vulnerable and frustrated replies
above, which both invite him to explain. It is a story line, not another scored
choice. Preserve each incoming path's accumulated empathy.

Aneska responds with the user's authored reassurance:

> hey, you will be okay. you are young, and eats healthy. I don't think it will be anything serious.

After her reassurance, return to the original dialogue:

> Yuvan: I just really miss you. It’s been a while.
>
> Aneska: I know - can I cuddle you to make it up?
>
> Yuvan: You’re not here though.
>
> Aneska: Peluk jauh!!!

Continue through the movie exchange and back to the pending astronaut topic.
The revised connecting lines are:

> Aneska: It’s okay, let’s watch that movie tomorrow.
>
> Yuvan: Okay. What was it your astronaut friend told you?

Then join `binary_star_intro` above. These shared story lines do not score or
reset empathy. The earlier warm route still joins directly at that introduction.

The user approved the warm option at the later shared choice joining directly
at "I just really miss you. It’s been a while." after Aneska says she is tired.
All three options at that choice now converge at this original line: warm joins
directly, while vulnerable and frustrated first share the fear and reassurance
exchange above. Each route keeps its accumulated empathy score.

All these beats and return paths are now in the main game.

### Continuity after the binary-star conversation

The banter settles into a brief affectionate exchange: Yuvan misses her jokes
and the way she makes him laugh after a bad day; Aneska likes hearing him laugh.
That relief brings him back to checking his phone earlier and needing this call.
Her apology now responds to that admission, rather than abruptly changing topics.

The later conflict remembers whether Aneska has already explained her tiredness.
If not, she gives that explanation. If she has, she instead says she should have
told him she wasn't up for the call yet. Both routes then reach the same player
choice about energy and attention. Yuvan's accusation is an available frustrated
option, not an automatic line.

`aneska_explained_tiredness` records that disclosure independently of empathy and
resets on restart. The astronaut topic is introduced once, and the late conflict
does not ask Yuvan to repeat the reason the specialist referral scares him.

## Choices through the relationship conflict

The author delegated dialogue, branching, and pacing to the assistant, requesting
character questions rather than approval for every dialogue permutation. The
following act is now implemented as a playable draft in `Conflict.ink`.

Current character interpretation: Aneska cares but feels overwhelmed and ashamed
that she cannot make things better; Yuvan fears that he only matters when he asks
to matter. Their conflict is about showing up, uncertainty, and autonomy. Neither
is reduced to being the villain. These character assumptions remain open to the
author's direction.

| Decision | Dramatic beat | Aneska's prompt tone | Warm / Vulnerable / Frustrated score |
| --- | --- | --- | --- |
| Energy and attention | Yuvan responds to her lack of energy instead of automatically accusing her. | Vulnerable | +1 / 0 / -1 |
| Room for friends | They distinguish having friendships from leaving someone waiting. | Frustrated | 0 / +1 / -1 |
| Fear of failing | Aneska doubts her ability to be a good partner; Yuvan chooses how to receive that. | Vulnerable | +1 / 0 / -1 |
| The old birthday wound | Staying after being asked means different things to each of them. | Frustrated | 0 / +1 / -1 |
| The breaking point | With both core fears finally spoken, Yuvan can slow down, explain his need, or push harder. | Vulnerable | +1 / 0 / -1 |
| What happens next | They try to name a change they can actually make. | Warm | +1 / 0 / -1 |

Each option has its own immediate Aneska response, then rejoins at the next
unresolved issue. The existing matrix applies once per committed choice and
retains the entire opening score. The 63 opening routes and 729 conflict-choice
sequences allow 45,927 full choice histories.

The birthday callback refers to **Aneska's friend's birthday party**, planned for
the evening before Yuvan went overseas. She stayed with Yuvan after he asked.
Tonight's waiting brings that memory back: he wanted to feel chosen without
having to ask, while she sees staying as evidence that she chose him. The scene
states whose party it was and when it happened before offering a response.

### Climax and recovery

The background stays calm through the first four conflict choices. The peak
comes when Aneska admits that being present feels like it will never be enough,
and Yuvan admits that he fears he only matters when he asks. `InitiateStorm()`
then starts the existing visual and music transition.

The storm spans both remaining choices and the exchange where Aneska admits
that her quick medical reassurance came from not knowing what to say. Yuvan
answers, "Neither do I. That's why I called you." This supplies new information
about her reaction without repeating his medical disclosure.

After the final choice, the total selects the resolution. Its opening exchange
establishes either reconnection or a decision to pause; only then does
`EndStorm()` begin the recovery. A calmer background means the confrontation has
ended, not that every route has repaired the relationship.

The close ending returns to the Nebula Entertainment joke and lets Aneska offer
to stay with Yuvan. The middle ending makes a limited agreement. The distant
ending leaves a difficult silence without forcing a breakup. All three remain
open to future character-led revisions.
