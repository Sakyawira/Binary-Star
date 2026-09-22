// Mechanical dialogue exercising the same scoring helper as the novel.
INCLUDE ../../Assets/Ink/Empathy.ink
VAR test_prompt_tone = TONE_WARM

An opening beat.
* [Warm reply.]
    ~ ScoreEmpathy(test_prompt_tone, TONE_WARM)
    A response to listening.
    -> shared
* [Vulnerable reply.]
    ~ ScoreEmpathy(test_prompt_tone, TONE_VULNERABLE)
    A neutral response.
    -> shared
* [Frustrated reply.]
    ~ ScoreEmpathy(test_prompt_tone, TONE_FRUSTRATED)
    A response to dismissal.
    -> shared

=== shared ===
A shared beat.
* [Continue.]
    {
    - aneska_empathy > 0:
        An empathic follow-up.
    - aneska_empathy < 0:
        A guarded follow-up.
    - else:
        A neutral follow-up.
    }
    -> repair

=== repair ===
+ [Make an effort.]
    ~ ScoreEmpathy(TONE_FRUSTRATED, TONE_VULNERABLE)
    After repair: {aneska_empathy}.
    -> repair
+ [End conversation.]
    Final empathy: {aneska_empathy}.
    -> END
