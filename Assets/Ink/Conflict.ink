// The relationship conflict continues the same cumulative empathy score.
// Six decisions: vulnerable, frustrated, vulnerable, frustrated, vulnerable, warm.
VAR final_empathy = 0
VAR ending_id = ""
VAR ending_title = ""
CONST CLOSE_ENDING_MIN = 5
CONST REACHING_ENDING_MIN = 0

=== energy_and_attention ===
“I missed this.” #Yuvan #NEUTRAL
“My terrible jokes?” #Aneska #HAPPY
“Yeah. You making me laugh, even when it's been a bad day.” #Yuvan #JOY
“I like hearing you laugh.” #Aneska #HAPPY
“I kept checking my phone earlier. I really needed a bit of this tonight.” #Yuvan #NEUTRAL
{aneska_explained_tiredness:
    “I know. I should have told you I wasn't up for the call yet. I'm sorry I left you waiting.” #Aneska #NEUTRAL
- else:
    “I know - I am so sorry. I just didn’t feel like I have the energy tonight.” #Aneska #HAPPY
}
~ aneska_explained_tiredness = true

* [I’m glad you had time with your friends. I just wish we’d had a little time for us, too.]
    ~ ScoreEmpathy(TONE_VULNERABLE, TONE_WARM)
    “I’m glad you had time with your friends. I just wish we’d had a little time for us, too.” #Yuvan #NEUTRAL
    “I wanted the night to stay easy for a little longer. That sounds selfish when I say it out loud.” #Aneska #NEUTRAL
    -> room_for_friends
* [I waited because I really needed you tonight. It hurts feeling like there’s no room left for me.]
    ~ ScoreEmpathy(TONE_VULNERABLE, TONE_VULNERABLE)
    “I waited because I really needed you tonight. It hurts feeling like there’s no room left for me.” #Yuvan #NEUTRAL
    “I kept looking at the time. I knew I was late. Then I felt guilty, and somehow that made calling harder.” #Aneska #SAD
    -> room_for_friends
* [Huh? So you have the energy to talk to your friends but not me? Why?]
    ~ ScoreEmpathy(TONE_VULNERABLE, TONE_FRUSTRATED)
    “Huh? So you have the energy to talk to your friends but not me? Why?” #Yuvan #ANGRY
    “With them I could just laugh. Here I knew you needed something I wasn't sure I could give.” #Aneska #ANGRY
    -> room_for_friends

=== room_for_friends ===
“But I don't want us to get to a place where seeing my friends means I've failed you.” #Aneska #ANGRY

* [I don’t want you to give them up. I want us to choose a time we can actually keep.]
    ~ ScoreEmpathy(TONE_FRUSTRATED, TONE_WARM)
    “I don’t want you to give them up. I want us to choose a time we can actually keep.” #Yuvan #NEUTRAL
    “That's fair. I should have told you the plan had changed before you spent the night waiting.” #Aneska #NEUTRAL
    -> afraid_of_failing
* [It isn’t that you went out. It’s that I waited, not knowing if you still wanted to be here.]
    ~ ScoreEmpathy(TONE_FRUSTRATED, TONE_VULNERABLE)
    “It isn’t that you went out. It’s that I waited, not knowing if you still wanted to be here.” #Yuvan #NEUTRAL
    “I thought apologizing for being late covered that. It didn't, did it?” #Aneska #NEUTRAL
    -> afraid_of_failing
* [Then why does time with me always seem like the thing you can cancel?]
    ~ ScoreEmpathy(TONE_FRUSTRATED, TONE_FRUSTRATED)
    “Then why does time with me always seem like the thing you can cancel?” #Yuvan #ANGRY
    “Always? Van, I missed tonight. Please don't make every time I did show up disappear.” #Aneska #ANGRY
    -> afraid_of_failing

=== afraid_of_failing ===
“I keep getting this wrong. Sometimes I wonder if I'm even ready for this relationship.” #Aneska #SAD

* [We can get things wrong and still want to be here. I love you, sayang.]
    ~ ScoreEmpathy(TONE_VULNERABLE, TONE_WARM)
    “We can get things wrong and still want to be here. I love you, sayang.” #Yuvan #JOY
    “I love you too. I just don't want those words to cover promises I keep failing to keep.” #Aneska #NEUTRAL
    -> old_wound
* [When you say that, I hear that needing you is too much. That scares me.]
    ~ ScoreEmpathy(TONE_VULNERABLE, TONE_VULNERABLE)
    “When you say that, I hear that needing you is too much. That scares me.” #Yuvan #NEUTRAL
    “You're not too much. I'm scared I'll promise to be better and hurt you the same way again.” #Aneska #SAD
    -> old_wound
* [So now the whole relationship is in question because I asked you to show up?]
    ~ ScoreEmpathy(TONE_VULNERABLE, TONE_FRUSTRATED)
    “So now the whole relationship is in question because I asked you to show up?” #Yuvan #ANGRY
    “I'm telling you something hard, Van. It isn't a way out of what you asked me.” #Aneska #ANGRY
    -> old_wound

=== old_wound ===
“Waiting tonight brought back the evening before I went overseas.” #Yuvan #NEUTRAL
“When I was going to my friend's birthday party?” #Aneska #NEUTRAL
“Yeah. It was our last evening together, and I had to ask you to stay.” #Yuvan #NEUTRAL
“And I did stay.” #Aneska #ANGRY

* [I know, and it mattered. I want you to understand why it still hurt.]
    ~ ScoreEmpathy(TONE_FRUSTRATED, TONE_WARM)
    “I know, and it mattered. I want you to understand why it still hurt.” #Yuvan #NEUTRAL
    “I thought staying was the answer. I didn't know the way I stayed could still hurt.” #Aneska #NEUTRAL
    -> breaking_point
* [I was leaving. I needed to feel that you would miss me as much as I would miss you.]
    ~ ScoreEmpathy(TONE_FRUSTRATED, TONE_VULNERABLE)
    “I was leaving. I needed to feel that you would miss me as much as I would miss you.” #Yuvan #NEUTRAL
    “I did miss you. I still do. I didn't understand that you needed to hear it before you left.” #Aneska #SAD
    -> breaking_point
* [Yeah—because I stopped you. If I hadn’t said anything, would you have gone?]
    ~ ScoreEmpathy(TONE_FRUSTRATED, TONE_FRUSTRATED)
    “Yeah—because I stopped you. If I hadn’t said anything, would you have gone?” #Yuvan #ANGRY
    “I can't prove what I would have done. I can tell you I stayed because I wanted to be with you.” #Aneska #ANGRY
    -> breaking_point

=== breaking_point ===
“I'm here now. But I'm scared that being here will never be enough.” #Aneska #SAD
“And I'm scared I only matter when I ask.” #Yuvan #NEUTRAL
~ InitiateStorm()
“I don't know how to do this without hurting you.” #Aneska #SAD

* [We can slow down. I want to understand you, too.]
    ~ ScoreEmpathy(TONE_VULNERABLE, TONE_WARM)
    “We can slow down. I want to understand you, too.” #Yuvan #NEUTRAL
    “Okay. Let me finish a thought before we try to solve it.” #Aneska #NEUTRAL
    -> what_she_could_not_say
* [I don’t need you to fix everything. I need to feel like you’re here with me.]
    ~ ScoreEmpathy(TONE_VULNERABLE, TONE_VULNERABLE)
    “I don’t need you to fix everything. I need to feel like you’re here with me.” #Yuvan #NEUTRAL
    “I can stay. I may need you to tell me what staying looks like.” #Aneska #NEUTRAL
    -> what_she_could_not_say
* [Then stop telling me you don’t know. I’m trying to tell you what I need.]
    ~ ScoreEmpathy(TONE_VULNERABLE, TONE_FRUSTRATED)
    “Then stop telling me you don’t know. I’m trying to tell you what I need.” #Yuvan #ANGRY
    “And I'm trying to tell you that being pushed harder isn't helping me hear you.” #Aneska #ANGRY
    -> what_she_could_not_say

=== what_she_could_not_say ===
“When you said specialist, I panicked. I said you'd be fine because I wanted it to be true.” #Aneska #NEUTRAL
“I don't know what to say when I can't promise something will be okay.” #Aneska #SAD
“Neither do I. That's why I called you.” #Yuvan #NEUTRAL
“I should have called you earlier. Even if all I could manage was saying I needed more time.” #Aneska #NEUTRAL
“What can we do differently next time?” #Aneska #HAPPY

* [If one of us can’t make the call, we say so. Then we pick a time and keep it.]
    ~ ScoreEmpathy(TONE_WARM, TONE_WARM)
    “If one of us can’t make the call, we say so. Then we pick a time and keep it.” #Yuvan #NEUTRAL
    “I can do that. And if I need space, I can say it instead of disappearing.” #Aneska #NEUTRAL
    -> resolve_conversation
* [Ask me one real question before trying to make the feeling go away.]
    ~ ScoreEmpathy(TONE_WARM, TONE_VULNERABLE)
    “Ask me one real question before trying to make the feeling go away.” #Yuvan #NEUTRAL
    “Okay. And I can let you finish before I try to answer.” #Aneska #NEUTRAL
    -> resolve_conversation
* [I shouldn’t have to write instructions for you to care about me.]
    ~ ScoreEmpathy(TONE_WARM, TONE_FRUSTRATED)
    “I shouldn’t have to write instructions for you to care about me.” #Yuvan #ANGRY
    “I can listen. I can't guess, and I can't be the only person who gets to be wrong tonight.” #Aneska #ANGRY
    -> resolve_conversation

=== resolve_conversation ===
~ final_empathy = aneska_empathy
{
- final_empathy >= CLOSE_ENDING_MIN:
    -> ending_closer
- final_empathy >= REACHING_ENDING_MIN:
    -> ending_reaching
- else:
    -> ending_distance
}

=== ending_closer ===
~ ending_id = "closer"
~ ending_title = "A little closer"
“I want us to be on the same side, Nes.” #Yuvan #NEUTRAL
“We are. I just forgot what being on your side looked like tonight.” #Aneska #NEUTRAL
~ EndStorm()
“When is the appointment?” #Aneska #HAPPY
“I haven't booked it yet.” #Yuvan #NEUTRAL
“Tell me when you do. We can talk before you go—and after, if you want.” #Aneska #HAPPY
“Yeah. I'd like that.” #Yuvan #JOY
“And tomorrow, a call before midnight. Your midnight.” #Aneska #HAPPY
“An actual appointment with you?” #Yuvan #JOY
“Very exclusive. Nebula Entertainment handles my bookings.” #Aneska #JOY
“Their gravity…” #Yuvan #JOY
“I know. Hard to leave.” #Aneska #JOY
“Good night, Nes.” #Yuvan #NEUTRAL
“Stay for a minute. You don't have to say anything.” #Aneska #HAPPY
“Okay.” #Yuvan #JOY
-> END

=== ending_reaching ===
~ ending_id = "reaching"
~ ending_title = "Still reaching"
“I don't think we can fix all of this tonight.” #Yuvan #NEUTRAL
“No. But I don't want another apology to be where we leave it.” #Aneska #NEUTRAL
~ EndStorm()
“Then one thing. Tomorrow, we choose a time before I start waiting.” #Yuvan #NEUTRAL
“And when you tell me you're scared, I'll ask before I reassure.” #Aneska #NEUTRAL
“I still feel scared.” #Yuvan #NEUTRAL
“I know. I won't try to argue you out of it.” #Aneska #NEUTRAL
“Can we leave the call on for a little bit?” #Yuvan #NEUTRAL
“A little bit. I do need to sleep soon.” #Aneska #NEUTRAL
“Okay. A little bit.” #Yuvan #NEUTRAL
-> END

=== ending_distance ===
~ ending_id = "distance"
~ ending_title = "A quiet distance"
“We're hurting each other now. I need to stop for tonight.” #Aneska #SAD
“Okay. I don't want to make this worse.” #Yuvan #NEUTRAL
~ EndStorm()
“I wanted to feel closer to you.” #Yuvan #NEUTRAL
“I know. I don't think we managed that tonight.” #Aneska #SAD
“Are we okay?” #Yuvan #NEUTRAL
“I don't know yet. I don't want to answer just to end the conversation.” #Aneska #SAD
“Then let's talk when we mean what we say.” #Yuvan #NEUTRAL
“Okay. Good night, Van.” #Aneska #NEUTRAL
“Good night.” #Yuvan #NEUTRAL
-> END
