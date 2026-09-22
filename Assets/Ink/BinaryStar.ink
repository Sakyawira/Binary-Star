VAR conversation_speed = 0
INCLUDE Empathy.ink
INCLUDE Opening.ink
INCLUDE Conflict.ink

// EXTERNAL ChangeBackground(place, time)

EXTERNAL InitiateStorm()
EXTERNAL EndStorm()

//~ChangeBackground("Planet", "Twilight")

-> late_night_call

=== missing_you ===
“I just really miss you. It’s been a while.”#Yuvan
“I know - can I cuddle you to make it up?” #Aneska #HAPPY
“You’re not here though.” #Yuvan #NEUTRAL
“Peluk jauh!!!” #Aneska #ANGRY
“Hehe. Okay - I feel better already! Do you still want to watch that movie? We might not finish it tonight though. I am getting really sleepy.”#Yuvan #NEUTRAL
“It’s okay, let’s watch that movie tomorrow.” #Aneska #HAPPY
“Okay. What was it your astronaut friend told you?” #Yuvan #NEUTRAL
-> binary_star_intro

=== binary_star_intro ===
“So apparently… there’s something called a binary star.” #Aneska #HAPPY
-> binary_star_banter

=== binary_star_banter ===
“What’s that? A new K-Pop group? Like Big Bang?”#Yuvan #NEUTRAL
“Yes - from Nebula Entertainment. Their visuals are astronomical! Don’t even get me started on their GRAVITY” #Aneska#ANGRY
“Uhh - what…?”#Yuvan #NEUTRAL
“No - it is not a K-Pop Band.” #Aneska#ANGRY
“Oh, so what is it then?”#Yuvan #NEUTRAL
“So - they are stars, like our Sun - but instead of solo - they go abouts in duets.” #Aneska#ANGRY
“Stahp.”#Yuvan #NEUTRAL
“Hahaha - but seriously though. Most stars in the Universe are Binary Stars. Some say even our Sun was once a Binary Star.” #Aneska#ANGRY
“What happened to our Sun’s partner?” #Yuvan#NEUTRAL
“Apparently they broke up.”#Aneska#ANGRY
“I see… Centrifugal force?”#Yuvan#NEUTRAL
“Yes - if two entities revolve around each other, the faster they move and the closer they are, the stronger they will push each other away”#Aneska#ANGRY
“Hooo - look at you showing off your physics knowledge”#Yuvan#NEUTRAL
“Mmmhm, it’s not like I need it for my profession or anything” #Aneska#ANGRY
“Hahaha - okay okay.”#Yuvan#NEUTRAL
-> energy_and_attention

// Original alternate branch and outro retained for reference.
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
