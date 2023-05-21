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

        [SerializeField]
        private UnityEvent<int> _musicPlayEvent;

        [SerializeField]
        private float _timeSinceLastContinue = 0;

        [SerializeField]
        private int _conversationSpeed = 0;

        public void InitiateStorm()
        {
            _musicPlayEvent.Invoke(1);
            _onStormInitiated.Invoke();
            _aneskaBackground.ChangeBackground("Planet", Hour.TWILIGHT);
            _yuvanBackground.ChangeBackground("Planet", Hour.TWILIGHT);
        }

        public void EndStorm()
        {
            _musicPlayEvent.Invoke(2);
            _onStormEnded.Invoke();
            _aneskaBackground.ChangeBackground("Planet", Hour.EVENING);
            _yuvanBackground.ChangeBackground("Planet", Hour.EVENING);
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
            _musicPlayEvent.Invoke(0);
            InvokeContinue();
        }

        private void Update()
        {
            _timeSinceLastContinue += Time.deltaTime;
        }

        public void InvokeContinue()
        {
            if (_dialogueEventCompletion == null)
            {
                if (_timeSinceLastContinue < 1000)
                {
                    _conversationSpeed = (int)_inkStory.variablesState["conversation_speed"];
                    _conversationSpeed++;
                    _inkStory.variablesState["conversation_speed"] = _conversationSpeed;
                }
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
            _timeSinceLastContinue = 0;
        }

        private void MakeChoice(int index)
        {
            _inkStory.ChooseChoiceIndex(index);
            Continue();
            _makeChoiceEvent.Invoke();
        }
    }
}
