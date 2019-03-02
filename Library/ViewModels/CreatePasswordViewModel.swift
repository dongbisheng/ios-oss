import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol CreatePasswordViewModelInputs {
  func newPasswordTextFieldChanged(text: String?)
  func newPasswordTextFieldDidReturn()
  func newPasswordConfirmationTextFieldChanged(text: String?)
  func newPasswordConfirmationTextFieldDidReturn()
  func viewDidAppear()
}

public protocol CreatePasswordViewModelOutputs {
  var newPasswordTextFieldBecomeFirstResponder: Signal<Void, NoError> { get }
  var newPasswordConfirmationTextFieldBecomeFirstResponder: Signal<Void, NoError> { get }
  var newPasswordConfirmationTextFieldResignFirstResponder: Signal<Void, NoError> { get }
  var validationLabelIsHidden: Signal<Bool, NoError> { get }
  var validationLabelText: Signal<String?, NoError> { get }
  var saveButtonIsEnabled: Signal<Bool, NoError> { get }

  func currentValidationLabelText() -> String?
}

public protocol CreatePasswordViewModelType {
  var inputs: CreatePasswordViewModelInputs { get }
  var outputs: CreatePasswordViewModelOutputs { get }
}

public class CreatePasswordViewModel: CreatePasswordViewModelType,
CreatePasswordViewModelInputs, CreatePasswordViewModelOutputs {
  public init() {
    self.newPasswordTextFieldBecomeFirstResponder = self.viewDidAppearProperty.signal
    self.newPasswordConfirmationTextFieldBecomeFirstResponder = self.newPasswordDidReturnProperty.signal
    self.newPasswordConfirmationTextFieldResignFirstResponder =
      self.newPasswordConfirmationDidReturnProperty.signal

    let combinedPasswords = Signal.combineLatest(
      self.newPasswordChangedProperty.signal.skipNil(),
      self.newPasswordConfirmationChangedProperty.signal.skipNil()
    )

    let validationMatch = combinedPasswords.map(passwordsMatch)
    let validationLength = self.newPasswordChangedProperty.signal.skipNil().map(passwordLengthValid)

    self.validationLabelText = Signal.combineLatest(validationMatch, validationLength)
      .map(passwordValidationText)
      .skipRepeats()

    self.currentValidationLabelTextProperty <~ self.validationLabelText

    let validationFields = Signal.combineLatest(
      self.newPasswordChangedProperty.signal.skipNil(),
      self.newPasswordConfirmationChangedProperty.signal.skipNil()
      ).map(passwordFieldsNotEmpty)

    let validationForm = Signal.combineLatest(validationFields, validationMatch, validationLength)
      .map(passwordFormValid)
      .skipRepeats()

    self.validationLabelIsHidden = validationForm
    self.saveButtonIsEnabled = validationForm
  }

  private var newPasswordChangedProperty = MutableProperty<String?>(nil)
  public func newPasswordTextFieldChanged(text: String?) {
    self.newPasswordChangedProperty.value = text
  }

  private var newPasswordDidReturnProperty = MutableProperty(())
  public func newPasswordTextFieldDidReturn() {
    self.newPasswordDidReturnProperty.value = ()
  }

  private var newPasswordConfirmationChangedProperty = MutableProperty<String?>(nil)
  public func newPasswordConfirmationTextFieldChanged(text: String?) {
    self.newPasswordConfirmationChangedProperty.value = text
  }

  private var newPasswordConfirmationDidReturnProperty = MutableProperty(())
  public func newPasswordConfirmationTextFieldDidReturn() {
    self.newPasswordConfirmationDidReturnProperty.value = ()
  }

  public let newPasswordTextFieldBecomeFirstResponder: Signal<Void, NoError>
  public let newPasswordConfirmationTextFieldBecomeFirstResponder: Signal<Void, NoError>
  public let newPasswordConfirmationTextFieldResignFirstResponder: Signal<Void, NoError>
  public let saveButtonIsEnabled: Signal<Bool, NoError>
  public let validationLabelIsHidden: Signal<Bool, NoError>
  public let validationLabelText: Signal<String?, NoError>

  private let currentValidationLabelTextProperty = MutableProperty<String?>(nil)
  public func currentValidationLabelText() -> String? {
    return self.currentValidationLabelTextProperty.value
  }

  private let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  public var inputs: CreatePasswordViewModelInputs {
    return self
  }

  public var outputs: CreatePasswordViewModelOutputs {
    return self
  }
}

// MARK: - Functions

private func passwordFieldsNotEmpty(_ pwds: (first: String, second: String)) -> Bool {
  return !pwds.first.isEmpty && !pwds.second.isEmpty
}
