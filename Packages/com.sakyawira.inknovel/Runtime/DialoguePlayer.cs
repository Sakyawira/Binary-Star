using System.Collections;
using System.Collections.Generic;
using Ink.Runtime;
using UnityEngine;
using UnityEngine.Events;

namespace Sakyawira.InkNovel
{
    public class DialoguePlayer : MonoBehaviour
    {
        [SerializeField]
        private TextAsset _inkJson;
        private Story _inkStory;
        [SerializeField]
        private UnityEvent<string> _dialogueEvent;
        [SerializeField]
        private TagTransposer _tagTransposer;
        [SerializeField]
        private UnityEvent<List<string>, UnityAction<int>> _revealChoicesEvent;
        [SerializeField]
        private UnityEvent _makeChoiceEvent;
        [SerializeField]
        private BackgroundChanger _background;

        private void Awake()
        {
            _inkStory = new Story(_inkJson.text);
            _inkStory.BindExternalFunction("ChangeBackground", _background.ChangeBackground);
        }

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.Space))
            {
                Continue();
            }
        }

        private void Continue()
        {
            if (_inkStory.canContinue)
            {
                string dialogue = _inkStory.Continue();
                Debug.Log(dialogue);
                _tagTransposer.TransposeTags(_inkStory.currentTags);
                _dialogueEvent.Invoke(dialogue);
            }
            else
            {
                if (_inkStory.currentChoices.Count > 0)
                {
                    _revealChoicesEvent.Invoke(new List<string>() { _inkStory.currentChoices[0].text, _inkStory.currentChoices[1].text, _inkStory.currentChoices[2].text }, MakeChoice);
                }
            }
        }

        private void MakeChoice(int index)
        {
            _inkStory.ChooseChoiceIndex(index);
            Continue();
            _makeChoiceEvent.Invoke();
        }
    }
}
