using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UIElements;

namespace Sakyawira.Interaction
{
    public class UIInteractionBus : MonoBehaviour
    {
        [SerializeField]
        private UIDocument _uiDocument;
        [SerializeField]
        private UnityEvent _actionOnInteraction;

        private void InvokeActionOnClick(ClickEvent clickEvent)
        {
            _actionOnInteraction.Invoke();
        }

        private void OnEnable()
        {
            _uiDocument.rootVisualElement.Q<Button>().RegisterCallback<ClickEvent>(InvokeActionOnClick);
        }

        //private void OnDisable()
        //{
        //    _uiDocument.rootVisualElement.Q<Button>().UnregisterCallback<ClickEvent>(InvokeActionOnClick);
        //}
    }
}
