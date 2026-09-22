// Shared scoring rules. Prompt = Aneska's tone; response = Yuvan's chosen tone.
VAR aneska_empathy = 0
CONST TONE_WARM = "warm"
CONST TONE_VULNERABLE = "vulnerable"
CONST TONE_FRUSTRATED = "frustrated"

=== function EmpathyDelta(prompt_tone, response_tone) ===
{prompt_tone:
- TONE_WARM:
    {response_tone:
    - TONE_WARM: ~ return 1
    - TONE_VULNERABLE: ~ return 0
    - TONE_FRUSTRATED: ~ return -1
    }
- TONE_VULNERABLE:
    {response_tone:
    - TONE_WARM: ~ return 1
    - TONE_VULNERABLE: ~ return 0
    - TONE_FRUSTRATED: ~ return -1
    }
- TONE_FRUSTRATED:
    {response_tone:
    - TONE_WARM: ~ return 0
    - TONE_VULNERABLE: ~ return 1
    - TONE_FRUSTRATED: ~ return -1
    }
}
~ return 0

=== function ScoreEmpathy(prompt_tone, response_tone) ===
~ temp delta = EmpathyDelta(prompt_tone, response_tone)
{delta != 0:
    ~ aneska_empathy += delta
}
~ return aneska_empathy
