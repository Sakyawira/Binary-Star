VAR conversation_speed = 1

// EXTERNAL ChangeBackground(place, time)

EXTERNAL InitiateStorm()
EXTERNAL EndStorm()

//~ChangeBackground("Planet", "Twilight")


“Yeah, I’m so sorry - how are you though?” #Aneska #ANGRY
“I just really miss you. It’s been a while.” #Yuvan #NEUTRAL

{
 -conversation_speed == 0 :
    -> A
 -conversation_speed > 0:
    -> B
}

== A ==

->END

== B ==
“I know - can I cuddle you to make it up?” #Aneska
~InitiateStorm()

->END