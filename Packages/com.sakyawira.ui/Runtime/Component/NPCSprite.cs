using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

namespace Sakyawira.UI
{
    public class NPCSprite : MonoBehaviour, ISpriteManipulator
    {
        [SerializeField]
        private UIDocument _uiDocument;

        // TODO: Might need a more sophisticated way to set starting state
        public void Start()
        {
            GreyOut();
        }

        public void ChangeSprite(Sprite sprite)
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").SetEnabled(true);
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").style.display = DisplayStyle.Flex;
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").style.backgroundImage = new StyleBackground(sprite);
        }

        public void TurnOffCharacterImage()
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").style.display = DisplayStyle.None;
        }

        public void GreyOut()
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").SetEnabled(false);
        }
    }
}
