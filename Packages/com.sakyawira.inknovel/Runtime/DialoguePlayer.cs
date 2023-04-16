using Cysharp.Threading.Tasks;
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
        private UnityEvent<string, UniTaskCompletionSource> _dialogueEvent;
        [SerializeField]
        private TagTransposer _tagTransposer;
        [SerializeField]
        private UnityEvent<List<string>, UnityAction<int>> _revealChoicesEvent;
        [SerializeField]
        private UnityEvent _makeChoiceEvent;
        [SerializeField]
        private BackgroundChanger _background;

        private UniTaskCompletionSource _dialogueEventCompletion;

        private void Start()
        {
            _inkStory = new Story(_inkJson.text);
            _inkStory.BindExternalFunction("ChangeBackground", _background.ChangeBackground);
        }

        private async void Update()
        {
            if (Input.GetKeyDown(KeyCode.Space) && _dialogueEventCompletion == null)
            {
                await Continue();
            }
        }

        private async UniTask Continue()
        {
            if (_inkStory.canContinue)
            {
                _dialogueEventCompletion = new UniTaskCompletionSource();
                string dialogue = _inkStory.Continue();
                Debug.Log(dialogue);
                _tagTransposer.TransposeTags(_inkStory.currentTags);
                _dialogueEvent.Invoke(dialogue, _dialogueEventCompletion);
                await _dialogueEventCompletion.Task;
                _dialogueEventCompletion = null;
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
