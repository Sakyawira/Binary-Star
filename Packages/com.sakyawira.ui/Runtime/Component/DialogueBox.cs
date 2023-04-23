using UnityEngine;
using UnityEngine.UIElements;
using Cysharp.Threading.Tasks;
using System.Collections.Generic;

namespace Sakyawira.UI
{
    public class DialogueBox : MonoBehaviour, ISpriteManipulator
    {
        [SerializeField]
        private VisualElement _currentElement;
        [SerializeField]
        private VisualElement _shiftedElement;

        [SerializeField]
        private UIDocument _currentDocument;
        [SerializeField]
        private UIDocument _shiftedDocument;

        [SerializeField]
        private VisualTreeAsset _dialogueBoxAsset;
        [SerializeField]
        private PanelSettings _panelSettings;

        // Make it so that each character has this dialogue box, and attach this to the dialogue start / end
        public void UpdateDialogue(string dialogue, UniTaskCompletionSource dialogueCompletion)
        {
            UpdateDialogueAsync(dialogue, dialogueCompletion).Forget();
        }

        public async UniTask UpdateDialogueAsync(string dialogue, UniTaskCompletionSource dialogueCompletion)
        {
            // if we have shifted document, we kill it
            if (_shiftedElement != null)
            {
                Destroy(_shiftedDocument.gameObject);
            }
            // if we have a previous box, we shift it up
            if (_currentElement != null)
            {
                _currentElement.AddToClassList("s-dialogue-box-transition");
                _shiftedElement = _currentElement;
                _shiftedDocument = _currentDocument;
            }
            // Spawn UI, queue it, make reference to it so taht we can maipualte the current one later
            _currentDocument = new GameObject().AddComponent<UIDocument>();
            _currentDocument.visualTreeAsset = _dialogueBoxAsset;
            _currentDocument.panelSettings = _panelSettings;
            _currentElement = _currentDocument.rootVisualElement.Q<VisualElement>("DialogueBox");
 
            for (int i = 0; i <= dialogue.Length; i++)
            {
                string currentText = dialogue.Substring(0, i);
                _currentElement.Q<Label>("Dialogue").text = currentText;
                await UniTask.Delay(65);
            }
            dialogueCompletion.TrySetResult();
        }

        public void UpdateCharacterName(string name)
        {
            _currentElement.Q<Label>("Name").style.display = DisplayStyle.Flex;
            _currentElement.Q<Label>("Name").text = name;
        }

        public void TurnOffCharacterName()
        {
            _currentElement.Q<Label>("Name").style.display = DisplayStyle.None;
        }

        public void TurnOffCharacterImage()
        {
            _currentElement.Q<VisualElement>("Image").style.display = DisplayStyle.None;
        }

        public void ChangeSprite(Sprite sprite)
        {
            _currentElement.Q<VisualElement>("Image").SetEnabled(true);
            _currentElement.Q<VisualElement>("Image").style.display = DisplayStyle.Flex;
            _currentElement.Q<VisualElement>("Image").style.backgroundImage = new StyleBackground(sprite);
        }

        public void GreyOut()
        {
            _currentElement.Q<VisualElement>("Image").SetEnabled(false);
        }
    }
}

