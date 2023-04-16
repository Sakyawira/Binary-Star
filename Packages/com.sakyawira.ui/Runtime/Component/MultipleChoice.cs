using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UIElements;

namespace Sakyawira.UI
{
    public class MultipleChoice : MonoBehaviour
    {
        [SerializeField]
        private UIDocument _uiDocument;

        private UnityAction<int> _chooseAction;

        private void Start()
        {
            _uiDocument.rootVisualElement.style.display = DisplayStyle.None;

            _uiDocument.rootVisualElement.Q<VisualElement>("0").Q<Button>().clicked += () => { Choose(0); };
            _uiDocument.rootVisualElement.Q<VisualElement>("1").Q<Button>().clicked += () => { Choose(1); };
            _uiDocument.rootVisualElement.Q<VisualElement>("2").Q<Button>().clicked += () => { Choose(2); };
        }

        public void ShowChoices(List<string> choices, UnityAction<int> choose)
        {
            _uiDocument.rootVisualElement.style.display = DisplayStyle.Flex;
            _uiDocument.rootVisualElement.Q<VisualElement>("0").Q<Button>().text = choices[0];
            _uiDocument.rootVisualElement.Q<VisualElement>("1").Q<Button>().text = choices[1];
            _uiDocument.rootVisualElement.Q<VisualElement>("2").Q<Button>().text = choices[2];
            _chooseAction = choose;
        }

        public void HideChoices()
        {
            _uiDocument.rootVisualElement.style.display = DisplayStyle.None;
            _chooseAction = null;
        }

        private void Choose(int index)
        {
            _chooseAction.Invoke(index);
        }
    }
}
