// Opening authoring preview. Yuvan's words are authored; Aneska's replies are drafts.
// Her opening is provisionally warm. This is independent of portrait emotion tags.
INCLUDE ../../Assets/Ink/Empathy.ink

“Oh my god, what time is it for you?” #Aneska #HAPPY

* [hi! don't worry about it - did you have a good day?]
    ~ ScoreEmpathy(TONE_WARM, TONE_WARM)
    “hi! don't worry about it - did you have a good day?” #Yuvan #JOY
    “Hi, sayang! It was a long day, but going out helped. How was yours?” #Aneska #HAPPY
    -> END
* [yeah it is quite late now, and I'm not feeling that great]
    ~ ScoreEmpathy(TONE_WARM, TONE_VULNERABLE)
    “yeah it is quite late now, and I'm not feeling that great” #Yuvan #NEUTRAL
    “Oh, Van… I’m sorry I wasn’t here. Do you want to tell me what happened?” #Aneska #NEUTRAL
    -> END
* [It is 2 am here… our call was supposed to be at 11 pm. Have you just arrived at your place?]
    ~ ScoreEmpathy(TONE_WARM, TONE_FRUSTRATED)
    “It is 2 am here… our call was supposed to be at 11 pm. Have you just arrived at your place?” #Yuvan #ANGRY
    “Yeah, I just got home. I’m sorry I kept you waiting… I didn’t realise how late it was.” #Aneska #NEUTRAL
    -> END
