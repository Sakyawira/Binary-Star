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
        [SerializeField]
        private Sprite _sprite;
        [SerializeField]
        private int _msPerFrame= 250;
        [SerializeField]
        private bool _isBackground = false;
        [SerializeField]
        private bool _loop = true;

        private int _animationIndex = 0;

        // TODO: Might need a more sophisticated way to set starting state
        public void Start()
        {
            GreyOut();
            ChangeSprite(_sprite);
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").schedule.Execute(AnimateSprite).Every(_msPerFrame);
            if (_isBackground)
            {
                _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").RemoveFromClassList("s-npc-sprite-zoom-in");
                _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").AddToClassList("s-background-sprite-zoom-in");
                if (_uiDocument.rootVisualElement.Q<VisualElement>("Container").ClassListContains("s-npc-sprite-container-alt"))
                {
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").RemoveFromClassList("s-npc-sprite-container-alt");
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").AddToClassList("s-background-sprite-container-alt-start");
                }
                else
                {
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").RemoveFromClassList("s-npc-sprite-container");
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").AddToClassList("s-background-sprite-container-start");
                }
            }
        }

        private void AnimateSprite(TimerState timerState)
        {
            if (_animate)
            {
                ChangeSprite(_sprites[_animationIndex]);
                _animationIndex++;
                if (_animationIndex == _sprites.Count)
                {
                    if (_loop)
                    {
                        _animationIndex = 0;
                    }
                    else
                    {
                        _animationIndex --;
                    }
                }
            }
        }
        
        [ContextMenu("ZoomIn")]
        public void ZoomIn()
        {
            if (_isBackground)
            {
                _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").RemoveFromClassList("s-background-sprite-zoom-out");
                _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").AddToClassList("s-background-sprite-zoom-in");
                if (_uiDocument.rootVisualElement.Q<VisualElement>("Container").ClassListContains("s-background-sprite-container-alt-end")) 
                {
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").AddToClassList("s-background-sprite-container-alt-start");
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").RemoveFromClassList("s-background-sprite-container-alt-end");
                }
                else
                {
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").AddToClassList("s-background-sprite-container-start");
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").RemoveFromClassList("s-background-sprite-container-end");
                }
                return;
            }
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").RemoveFromClassList("s-npc-sprite-zoom-out");
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").AddToClassList("s-npc-sprite-zoom-in");
        }

        [ContextMenu("ZoomOut")]
        public void ZoomOut()
        {
            if (_isBackground)
            {
                _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").AddToClassList("s-background-sprite-zoom-out");
                _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").RemoveFromClassList("s-background-sprite-zoom-in");
                if (_uiDocument.rootVisualElement.Q<VisualElement>("Container").ClassListContains("s-background-sprite-container-alt-start"))
                {
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").AddToClassList("s-background-sprite-container-alt-end");
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").RemoveFromClassList("s-background-sprite-container-alt-start");
                }
                else
                {
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").AddToClassList("s-background-sprite-container-end");
                    _uiDocument.rootVisualElement.Q<VisualElement>("Container").RemoveFromClassList("s-background-sprite-container-start");
                }
                return;
            }
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").AddToClassList("s-npc-sprite-zoom-out");
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").RemoveFromClassList("s-npc-sprite-zoom-in");
        }

        public void ChangeSprite(Sprite sprite)
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").style.display = DisplayStyle.Flex;
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").style.backgroundImage = new StyleBackground(sprite);
        }

        public void ChangeSpriteSet(List<Sprite> sprites, Sprite singleSprite)
        {
            _animate = true;
            _animationIndex = 0;
            _sprites = sprites;
            _sprite = singleSprite;
        }

        public void TurnOffCharacterImage()
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").style.display = DisplayStyle.None;
        }

        public void Highlight() 
        {
            _animate = false;
            ChangeSprite(_sprite);
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").SetEnabled(true);
        }

        public void GreyOut()
        {
            _uiDocument.rootVisualElement.Q<VisualElement>("Sprite").SetEnabled(false);
        }
    }
}
