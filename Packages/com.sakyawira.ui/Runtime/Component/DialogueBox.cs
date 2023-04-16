using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UIElements;


namespace Sakyawira.UI
{
    public class DialogueBox : MonoBehaviour, ISpriteManipulator
    {
        [SerializeField]
        private UIDocument _uiDocument;

        public void UpdateDialogue(string dialogue)
        {
            _uiDocument.rootVisualElement.Q<Label>("Dialogue").text = dialogue;
        }

        public void UpdateCharacterName(string name)
        {
            _uiDocument.rootVisualElement.Q<Label>("Name").style.display = DisplayStyle.Flex;
            _uiDocument.rootVisualElement.Q<Label>("Name").text = name;
        }

        public void TurnOffCharacterName()
        {
            _uiDocument.rootVisualElement.Q<Label>("Name").style.display = DisplayStyle.None;
        }

        public void TurnOffCharacterImage()
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Image").style.display = DisplayStyle.None;
        }

        public void ChangeSprite(Sprite sprite)
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Image").SetEnabled(true);
            _uiDocument.rootVisualElement.Q<VisualElement>("Image").style.display = DisplayStyle.Flex;
            _uiDocument.rootVisualElement.Q<VisualElement>("Image").style.backgroundImage = new StyleBackground(sprite);
        }

        public void GreyOut()
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Image").SetEnabled(false);
        }
    }
}

