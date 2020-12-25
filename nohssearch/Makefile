include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NoHSSearch

NoHSSearch_FILES = NHSSRootListController.m
NoHSSearch_INSTALL_PATH = /Library/PreferenceBundles
NoHSSearch_FRAMEWORKS = UIKit MessageUI
NoHSSearch_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NoHSSearch.plist$(ECHO_END)
