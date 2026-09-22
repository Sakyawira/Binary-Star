// Yuvan's playable opening, authored in docs/STORY_WORKSHOP.md.
// Prompt tones are independent of portrait tags. Current working assignments:
// the opening, check-in, and topic change are warm; the impatient replies are frustrated.
VAR aneska_explained_tiredness = false

=== late_night_call ===
“Oh my god, what time is it for you?” #Aneska #HAPPY

* [hi! don't worry about it - did you have a good day?]
    ~ ScoreEmpathy(TONE_WARM, TONE_WARM)
    “hi! don't worry about it - did you have a good day?” #Yuvan #JOY
    “Hi, sayang! It was a long day, but going out helped.” #Aneska #HAPPY
    -> how_was_your_day(false)
* [yeah it is quite late now, and I'm not feeling that great]
    ~ ScoreEmpathy(TONE_WARM, TONE_VULNERABLE)
    “yeah it is quite late now, and I'm not feeling that great” #Yuvan #NEUTRAL
    “Oh, Van… I’m sorry I wasn’t here.” #Aneska #NEUTRAL
    -> how_was_your_day(true)
* [It is 2 am here… our call was supposed to be at 11 pm. Have you just arrived at your place?]
    ~ ScoreEmpathy(TONE_WARM, TONE_FRUSTRATED)
    “It is 2 am here… our call was supposed to be at 11 pm. Have you just arrived at your place?” #Yuvan #ANGRY
    “Yeah, I just got home. I’m sorry I kept you waiting… I didn’t realise how late it was.” #Aneska #NEUTRAL
    -> how_was_your_day(false)

=== how_was_your_day(already_said_unwell) ===
{already_said_unwell:
    “Was today that bad?” #Aneska #HAPPY
- else:
    “How are you, though?” #Aneska #HAPPY
}

* [It was pretty bad. But talking to you right now makes it better already.]
    ~ ScoreEmpathy(TONE_WARM, TONE_WARM)
    “It was pretty bad. But talking to you right now makes it better already.” #Yuvan #JOY
    “Awww, okay.” #Aneska #HAPPY
    -> doctor_visit
* [I felt so... alone. Like nobody is on my side and helping me through things.]
    ~ ScoreEmpathy(TONE_WARM, TONE_VULNERABLE)
    “I felt so... alone. Like nobody is on my side and helping me through things.” #Yuvan #NEUTRAL
    “Right.” #Aneska #NEUTRAL
    -> doctor_visit
* [you know.... it was bad, but you not being here on time makes it even worse]
    ~ ScoreEmpathy(TONE_WARM, TONE_FRUSTRATED)
    “you know.... it was bad, but you not being here on time makes it even worse” #Yuvan #ANGRY
    “Yeah, well, I was hanging out with my friends.” #Aneska #ANGRY
    -> doctor_visit

=== doctor_visit ===
“So, what happened? what makes you feel that way?” #Aneska #NEUTRAL
“I went to the Doctor, and ugh... he told me I should see the specialist just in case. He said it is probably nothing, but it is making me anxious” #Yuvan #NEUTRAL
“I think it should be fine. Anyway, do you wanna know what I heard from my friend who is an Astronaut?” #Aneska #HAPPY

* [An astronaut? Okay, you’ve got me curious. What did they say?]
    ~ ScoreEmpathy(TONE_WARM, TONE_WARM)
    “An astronaut? Okay, you’ve got me curious. What did they say?” #Yuvan #JOY
    -> binary_star_intro
* [I do wanna hear it, but... can we stay with this for a little longer? I’m still feeling anxious.]
    ~ ScoreEmpathy(TONE_WARM, TONE_VULNERABLE)
    “I do wanna hear it, but... can we stay with this for a little longer? I’m still feeling anxious.” #Yuvan #NEUTRAL
    “Oh—I thought you were done. So what else do you want to talk about in regards to that?” #Aneska #NEUTRAL
    -> ask_for_support(TONE_FRUSTRATED)
* [Seriously? I just told you what happened, and you’re already changing the subject?]
    ~ ScoreEmpathy(TONE_WARM, TONE_FRUSTRATED)
    “Seriously? I just told you what happened, and you’re already changing the subject?” #Yuvan #ANGRY
    “Okay, okay. Just starts talking about it then... quick” #Aneska #ANGRY
    -> ask_for_support(TONE_FRUSTRATED)

=== ask_for_support(prompt_tone) ===
* [Hey, what's wrong? I feel like you are being a bit harsh towards me.]
    ~ ScoreEmpathy(prompt_tone, TONE_WARM)
    “Hey, what's wrong? I feel like you are being a bit harsh towards me.” #Yuvan #NEUTRAL
    “Sigh. I'm just realy tired. And I really don't feel like talking right now” #Aneska #SAD
    ~ aneska_explained_tiredness = true
    -> missing_you
* [I don't know. I'm just so anxious. It would make me feel better if you'd actually ask me follow up questions that makes me feel like you care about me]
    ~ ScoreEmpathy(prompt_tone, TONE_VULNERABLE)
    “I don't know. I'm just so anxious. It would make me feel better if you'd actually ask me follow up questions that makes me feel like you care about me” #Yuvan #NEUTRAL
    “Sigh, okay. So what is it in particular making you feel anxious about this... whole deal?” #Aneska #NEUTRAL
    -> fear_and_reassurance
* [What.... You sound like you don't really want to know.]
    ~ ScoreEmpathy(prompt_tone, TONE_FRUSTRATED)
    “What.... You sound like you don't really want to know.” #Yuvan #ANGRY
    “No, I do want to know. Come on, just say what you need to say.” #Aneska #ANGRY
    -> fear_and_reassurance

=== fear_and_reassurance ===
“It is just you know.... what if it is something that is sinister.” #Yuvan #NEUTRAL
“hey, you will be okay. you are young, and eats healthy. I don't think it will be anything serious.” #Aneska #HAPPY
-> missing_you
