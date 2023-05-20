VAR conversation_speed = 1

EXTERNAL ChangeBackground(place, time)

~ChangeBackground("Planet", "Twilight")

“Yeah, I’m so sorry - how are you though?” #Aneska #ANGRY

{
 -conversation_speed == 0 :
    -> A
 -conversation_speed > 0:
    -> B
}

== A ==
“I just really miss you. It’s been a while.” #Yuvan
->END

== B ==
“I know - can I cuddle you to make it up?” #Aneska


->END