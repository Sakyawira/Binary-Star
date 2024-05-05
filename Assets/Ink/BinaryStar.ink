VAR conversation_speed = 0

// EXTERNAL ChangeBackground(place, time)

EXTERNAL InitiateStorm()
EXTERNAL EndStorm()

//~ChangeBackground("Planet", "Twilight")

// “Oh my god, what time is it for you?” #Aneska #HAPPY
//  “It is 2 am here… our call was supposed to be at 11 pm. Have you just arrived at your place?”#Yuvan #NEUTRAL
// “Yeah, I’m so sorry - how are you though?” #Aneska #HAPPY
// “Terrible, depressed.”#Yuvan #NEUTRAL
// “....” #Aneska #HAPPY
// “I just really miss you. It’s been a while.”#Yuvan
// “I know - can I cuddle you to make it up?” #Aneska #HAPPY
// “You’re not here though.” #Yuvan #NEUTRAL
// “Peluk jauh!!!” #Aneska #ANGRY
// “Hehe. Okay - I feel better already! Do you still want to watch that movie? We might not finish it tonight though. I am getting really sleepy.”#Yuvan #NEUTRAL
// “It’s okay, let’s watch that movie tomorrow. I do have a topic I want to talk about for tonight.” #Aneska#ANGRY
// “Okay - let’s hear it!”#Yuvan #NEUTRAL
// “I learned about Binary Star today” #Aneska#ANGRY
// “What’s that? A new K-Pop group? Like Big Bang?”#Yuvan #NEUTRAL
// “Yes - from Nebula Entertainment. Their visuals are astronomical! Don’t even get me started on their GRAVITY” #Aneska#ANGRY
// “Uhh - what…?”#Yuvan #NEUTRAL
// “No - it is not a K-Pop Band.” #Aneska#ANGRY
// “Oh, so what is it then?”#Yuvan #NEUTRAL
// “So - they are stars, like our Sun - but instead of solo - they go abouts in duets.” #Aneska#ANGRY
// “Stahp.”#Yuvan #NEUTRAL
// “Hahaha - but seriously though. Most stars in the Universe are Binary Stars. Some say even our Sun was once a Binary Star.” #Aneska#ANGRY
// “What happened to our Sun’s partner?” #Yuvan#NEUTRAL
// “Apparently they broke up.”#Aneska#ANGRY
// “I see… Centrifugal force?”#Yuvan#NEUTRAL
// “Yes - if two entities revolve around each other, the faster they move and the closer they are, the stronger they will push each other away”#Aneska#ANGRY
// “Hooo - look at you showing off your physics knowledge”#Yuvan#NEUTRAL
// “Mmmhm, it’s not like I need it for my profession or anything” #Aneska#ANGRY
// “Hahaha - okay okay.”#Yuvan#NEUTRAL
// “So - what about you? Any topic for your girlfriend?”#Aneska#ANGRY
// “Okay so I do have something that’s been bothering me.”#Yuvan#NEUTRAL
// “Go on.”#Aneska#ANGRY
// “Okay... So, why did you come home so late? I did tell you that I had a really rough time at work and I want to TALK to YOU about it, right?”#Yuvan #ANGRY
// “I know - I am so sorry. I just didn’t feel like I have the energy tonight.”#Aneska#HAPPY
// “Huh? So you have the energy to talk to your friends but not me? Why?”#Yuvan #ANGRY
// “Yes - I know I am being selfish. But I also had a hard time at work. I just … I just needed to have fun!”#Aneska#ANGRY
// “I see - is there someone among your friends that you really want to have fun with?”#Yuvan #ANGRY
// “What? No!”#Aneska#HAPPY
// “Right - sorry, of course it’s not like that.”#Yuvan #ANGRY
// “Sigh”#Aneska#HAPPY
// “I just feel like you prioritize your friends more than me - the last time we had a good long conversation was a long time ago.”#Yuvan #ANGRY
// “I know, but I do have to maintain my friendships with them. I will be hanging out with you every week once and while you are back, by that time I will have no chance to hang out with my friends”#Aneska#HAPPY
// “Yeah - I understand. Your argument makes total sense. And so I have been trying to feel better about this - I hung out with a lot of friends the last couple of weeks, I have been intensifying my workout routines, but just somehow - somehow I still want and need to spend time with you.”#Yuvan #ANGRY
// “I see - but well I do not know how to respond. I hope I can fulfill your needs. But I am not ready to do that yet. Maybe I am just not ready for this relationship after all.”#Aneska#HAPPY
// “I - I don’t think that is the case. The fact that we are having this conversation without screaming our lungs out is a testament to that. I love you, sayang.”#Yuvan #JOY
// “Yeah, but the way I love you is not enough, isn’t it? It breaks my heart to know that I keep hurting you.”#Aneska#HAPPY
// “Hey, I am okay. I do get hurt sometimes, but you have done so much for me too. These things happen to every couple. Remember that time you helped me through the conflict with my parents? It would have not been easy for me to accept if it was anyone else but you.”#Yuvan #JOY
// “Thank you and - I’m sorry. You always ended up being the one to comfort me, even though you are the one who is hurting.”#Aneska#HAPPY
// “It’s okay - I still want to talk about my feelings though, do you think you can do it now?”#Yuvan #JOY
// “Sure - let’s not delay it.”#Aneska#HAPPY
// “Well, yeah I think I just want to feel that you do love me more than your friends - that I am your number one.”#Yuvan #ANGRY
“I do - you are”#Aneska#HAPPY
“Can you remind me how much? I remember the last time you chose to go out with your friend's birthday even though that night will also be the night before I left overseas.”#Yuvan #ANGRY

// {
//  -conversation_speed == 0 :
//     -> BRANCH1
//  -conversation_speed > 0:
//     -> BRANCH2
// }

// === BRANCH1 ===
~InitiateStorm()

“I didn’t end up going.” #Aneska#HAPPY
“Yeah - cause I stopped you, right?#Yuvan #ANGRY
// “Yes… But I also wanted to…?”#Aneska #JOY
// “I feel like if you had wanted to, you would’ve not gone in the first place.”#Yuvan #HAPPY
//  “That’s… not fair? I told you, you can always tell me if things made you upset right?”#Aneska #JOY
// “Yeah, but even when I’m already tired, I’m always the one who has to think about it.”#Yuvan #HAPPY
// “And you think I haven’t thought about it?”#Aneska #JOY
// “It’s just that I always have to point this out to you”#Yuvan #HAPPY
// “Okay I am sorry. Then maybe I haven’t been enough for you.”#Aneska #JOY
// “Come on, I told you…”#Yuvan #HAPPY
// “I’m sorry.”#Aneska #JOY
// “Thank you for saying sorry, but can you please give me your thoughts?”#Yuvan #HAPPY
// “What thoughts?”#Aneska #JOY
// “On why it seems so hard for you to give me what I need when I’m literally spelling it out for you!”#Yuvan #HAPPY
// “Well I also don’t know why you can’t see that I’m trying!”#Aneska #JOY
// “And I’m just trying to address my pain? I have been trying to understand you, so why can’t you just be patient with me?”#Yuvan #HAPPY
// “I don’t know - please don’t make me think.”#Aneska #JOY
// “Well, then what are we going to do about this??”#Yuvan #HAPPY
// “I said I don’t know!!!”#Aneska #JOY


~EndStorm()

“So… Are you ready to talk again?” #Yuvan #ANGRY
“Yeah - thank you, I needed that” #Aneska #HAPPY
I’m really sorry, sayang… I was being hurtful to you. I really didn’t want to… I see that you were just trying to communicate what you need." #Aneska #HAPPY
"Yeah, it’s okay. I didn’t need you to be perfect. I’m not either. And I’m sorry I hurt you too."#Yuvan #ANGRY
"I love you. I want to learn to be a better partner to you…"#Aneska #HAPPY
"It’s not just you, Nes. A relationship is between two people.  I’ll also learn how to be happy for you."#Yuvan #ANGRY
"Can’t I be part of that?"#Aneska #HAPPY


-> OUTRO



=== BRANCH2 ===
“I didn’t end up going, though, right? Because you told me that you needed me.”#Aneska#ANGRY
 “Yeah… But if I didn’t say it would you still have gone?”#Yuvan #ANGRY
“Van, I love you very much, and I’m sorry I was not sensitive to your feelings at that time. I really just want to make you comfortable. It was never my intention to hurt you.”#Aneska#HAPPY
 “I guess you’re right…”#Yuvan #ANGRY
“Mmhm, and I appreciate you telling me about this. We can’t do anything if we don’t know what the problem is right?”#Aneska#ANGRY
“Nes… Thank you for being patient with me. I’m sorry I got emotional back there. I know you’re tired too…”#Yuvan #ANGRY
 “I’m sorry if I hurt you too… I just want to be a good partner to you.”#Aneska#HAPPY


-> OUTRO

=== OUTRO ===

 "You already are." #Yuvan #JOY
"You know you’re precious to me, right?"#Aneska#ANGRY
"Tell me how?" #Yuvan #JOY
"You know, binary stars get brighter when they’re together. Even more than single ones." #Aneska#ANGRY
"Now, that’s a full circle." #Yuvan #JOY
"Guess so… #Aneska#ANGRY
"You won’t leave me alone like the sun?" #Yuvan #JOY
"..." #Aneska#SAD
"Nes…?" #Yuvan #ANGRY
"..."#Aneska#SAD
"She falls asleep!" #Yuvan #JOY
"Mmm…?"#Aneska#SAD
"Hehe, it’s okay, it’s been a long day. Let’s talk about it tomorrow, okay?" #Yuvan #JOY
"Mmm... Good night... Love you..."#Aneska#SAD
"Good night. I love you too..."#Yuvan #JOY

-> END