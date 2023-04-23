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
        [SerializeField]
        private bool _animate = false;
        [SerializeField]
        private List<Sprite> _sprites;

        private int _animationIndex = 0;

        // TODO: Might need a more sophisticated way to set starting state
        public void Start()
        {
            GreyOut();
            if (_animate)
            {
                _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").schedule.Execute(AnimateSprite).Every(250);
            }
        }

        private void AnimateSprite(TimerState timerState)
        {
            ChangeSprite(_sprites[_animationIndex]);
            _animationIndex++;
            if (_animationIndex == _sprites.Count)
            {
                _animationIndex = 0;
            }
        }

        public void ChangeSprite(Sprite sprite)
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").style.display = DisplayStyle.Flex;
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").style.backgroundImage = new StyleBackground(sprite);
        }

        public void ChangeSpriteSet(List<Sprite> sprites)
        {
            _animationIndex = 0;
            _sprites = sprites;
        }

        public void TurnOffCharacterImage()
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").style.display = DisplayStyle.None;
        }

        public void Highlight() 
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").SetEnabled(true);
        }

        public void GreyOut()
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").SetEnabled(false);
        }
    }
}
