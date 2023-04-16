using UnityEngine;
using UnityEngine.UIElements;
using Cysharp.Threading.Tasks;

namespace Sakyawira.UI
{
    public class DialogueBox : MonoBehaviour, ISpriteManipulator
    {
        [SerializeField]
        private UIDocument _uiDocument;

        public void UpdateDialogue(string dialogue, UniTaskCompletionSource dialogueCompletion)
        {
            UpdateDialogueAsync(dialogue, dialogueCompletion).Forget();
        }

        public async UniTask UpdateDialogueAsync(string dialogue, UniTaskCompletionSource dialogueCompletion)
        {
            for (int i = 0; i <= dialogue.Length; i++)
            {
                string currentText = dialogue.Substring(0, i);
                _uiDocument.rootVisualElement.Q<Label>("Dialogue").text = currentText;
                await UniTask.Delay(65);
            }
            dialogueCompletion.TrySetResult();
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

