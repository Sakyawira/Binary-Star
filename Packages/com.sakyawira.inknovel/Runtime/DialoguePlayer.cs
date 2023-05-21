using Cysharp.Threading.Tasks;
using System.Collections.Generic;
using Ink.Runtime;
using UnityEngine;
using UnityEngine.Events;
using System;

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
        private BackgroundChanger _aneskaBackground;
        [SerializeField]
        private BackgroundChanger _yuvanBackground;

        private UniTaskCompletionSource _dialogueEventCompletion;

        [SerializeField]
        private UnityEvent _gameStartEvent;

        public Func<string, string, string> ChangeBackground;

        [SerializeField]
        private UnityEvent _onStormInitiated;

        [SerializeField]
        private UnityEvent _onStormEnded;

        public void InitiateStorm()
        {
            _onStormInitiated.Invoke();
            _aneskaBackground.ChangeBackground("Planet", Time.TWILIGHT);
            _yuvanBackground.ChangeBackground("Planet", Time.TWILIGHT);
        }

        public void EndStorm()
        {
            _onStormEnded.Invoke();
            _aneskaBackground.ChangeBackground("Planet", Time.TWILIGHT);
            _yuvanBackground.ChangeBackground("Planet", Time.TWILIGHT);
        }

        private void Awake()
        {
            ChangeBackground += _aneskaBackground.ChangeBackground;
            ChangeBackground += _yuvanBackground.ChangeBackground;
            _inkStory = new Story(_inkJson.text);
            _inkStory.BindExternalFunction("ChangeBackground", ChangeBackground);
            _inkStory.BindExternalFunction("InitiateStorm", InitiateStorm);
            _inkStory.BindExternalFunction("EndStorm", EndStorm);
        }

        private void Start()
        {
            InvokeContinue();
        }

        public void InvokeContinue()
        {
            if (_dialogueEventCompletion == null)
            {
                Continue().Forget();
            }
        }

        private async UniTask Continue()
        {
            if (_inkStory.canContinue)
            {
                _dialogueEventCompletion = new UniTaskCompletionSource();
                string dialogue = _inkStory.Continue();
                Debug.Log(dialogue);
                var dialogueEndEvent = _tagTransposer.TransposeTags(_inkStory.currentTags);
                _dialogueEvent.Invoke(dialogue, _dialogueEventCompletion);
                await _dialogueEventCompletion.Task;
                dialogueEndEvent?.Invoke();
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
