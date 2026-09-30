import 'package:flutter/material.dart';

/// Ilova matnlari — o'zbek va rus tillari.
///
/// Kod generatsiyasiga tayanmaydi: barcha matnlar `const` obyektlarda
/// saqlanadi va `LocalizationsDelegate` orqali kontekstga ulanadi.
/// Yangi matn qo'shganda ikkala tilni ham to'ldirish shart.
@immutable
class AppStrings {
  const AppStrings({
    required this.localeCode,
    required this.appName,
    required this.slogan,
    required this.onboardingTitle1,
    required this.onboardingBody1,
    required this.onboardingTitle2,
    required this.onboardingBody2,
    required this.onboardingTitle3,
    required this.onboardingBody3,
    required this.next,
    required this.start,
    required this.skip,
    required this.greeting,
    required this.notifications,
    required this.statSales,
    required this.statProfit,
    required this.statDebtGiven,
    required this.statDebtReturned,
    required this.quickSale,
    required this.quickDebt,
    required this.quickPayment,
    required this.quickStockIn,
    required this.attentionNeeded,
    required this.overdueDebtsTemplate,
    required this.lowStockTemplate,
    required this.view,
    required this.viewInventory,
    required this.todayTitle,
    required this.todaySummaryTemplate,
    required this.navHome,
    required this.navCustomers,
    required this.navDebts,
    required this.navInventory,
    required this.navSettings,
    required this.proTitle,
    required this.proBody,
    required this.proAction,
    required this.comingSoonTitle,
    required this.comingSoonBody,
    required this.cancel,
    required this.confirm,
    required this.save,
    required this.searchHint,
    required this.logout,
    required this.authTitle,
    required this.authSubtitle,
    required this.phoneLabel,
    required this.phoneHint,
    required this.sendSmsCode,
    required this.orDivider,
    required this.continueWithGoogle,
    required this.otpTitle,
    required this.otpSubtitle,
    required this.otpResend,
    required this.otpResendTemplate,
    required this.back,
    required this.continueLabel,
    required this.profileTitle,
    required this.profileSubtitle,
    required this.nameLabel,
    required this.nameHint,
    required this.shopNameLabel,
    required this.shopNameHint,
    required this.businessTypeQuestion,
    required this.businessClothes,
    required this.businessFood,
    required this.businessShoes,
    required this.businessAppliances,
    required this.businessOther,
    required this.pinCreateTitle,
    required this.pinCreateSubtitle,
    required this.pinConfirmTitle,
    required this.pinConfirmSubtitle,
    required this.pinRemember,
    required this.pinMismatch,
    required this.pinUnlockTitle,
    required this.pinUnlockSubtitle,
    required this.pinForgot,
    required this.errorNetwork,
    required this.errorUnknown,
    required this.validationPhoneInvalid,
    required this.validationNameRequired,
    required this.validationOtpInvalid,
    required this.customerAddTitle,
    required this.customerEditTitle,
    required this.filterAll,
    required this.filterDebtors,
    required this.filterClean,
    required this.customersEmptyTitle,
    required this.customersEmptyBody,
    required this.searchEmptyTitle,
    required this.searchEmptyBody,
    required this.phoneOptionalLabel,
    required this.addressLabel,
    required this.addressHint,
    required this.noteLabel,
    required this.noteHint,
    required this.balanceLabel,
    required this.customerDebtLabel,
    required this.noDebtLabel,
    required this.historyTitle,
    required this.historyEmptyTitle,
    required this.historyEmptyBody,
    required this.acceptPaymentTitle,
    required this.amountLabel,
    required this.payCash,
    required this.payCard,
    required this.validationAmountInvalid,
    required this.validationAmountExceedsTemplate,
    required this.edit,
    required this.delete,
    required this.deleteCustomerTitle,
    required this.deleteCustomerBody,
    required this.retry,
    required this.historyDebt,
    required this.historyPayment,
    required this.historySale,
    required this.overdueLabel,
    required this.debtAddTitle,
    required this.filterOpen,
    required this.filterOverdue,
    required this.filterPaid,
    required this.totalOutstanding,
    required this.overdueAmountLabel,
    required this.debtorsCountTemplate,
    required this.debtsEmptyTitle,
    required this.debtsEmptyBody,
    required this.customerLabel,
    required this.selectCustomerTitle,
    required this.validationCustomerRequired,
    required this.dueDateOptionalLabel,
    required this.dueDateShort,
    required this.paidLabel,
    required this.remainingLabel,
    required this.statusOpen,
    required this.statusPartial,
    required this.statusPaid,
    required this.paymentsTitle,
    required this.paymentsEmptyTitle,
    required this.deleteDebtTitle,
    required this.deleteDebtBody,
    required this.clearLabel,
    required this.productAddTitle,
    required this.productEditTitle,
    required this.filterLowStock,
    required this.filterOutOfStock,
    required this.productsEmptyTitle,
    required this.productsEmptyBody,
    required this.productNameLabel,
    required this.productNameHint,
    required this.categoryLabel,
    required this.categoryHint,
    required this.barcodeLabel,
    required this.unitLabel,
    required this.buyPriceLabel,
    required this.sellPriceLabel,
    required this.initialStockLabel,
    required this.minStockLabel,
    required this.marginLabel,
    required this.stockLabel,
    required this.stockOutTitle,
    required this.qtyLabel,
    required this.updateBuyPriceLabel,
    required this.movementsTitle,
    required this.movementsEmptyTitle,
    required this.deleteProductTitle,
    required this.deleteProductBody,
    required this.validationProductNameRequired,
    required this.validationSellPriceRequired,
    required this.stockValueLabel,
    required this.productsCountTemplate,
    required this.adjustLabel,
    required this.returnLabel,
    required this.saleNewTitle,
    required this.salesHistoryTitle,
    required this.cartTitle,
    required this.addProductLabel,
    required this.selectProductTitle,
    required this.quickAddProductTitle,
    required this.payDebtLabel,
    required this.payMixed,
    required this.paymentMethodLabel,
    required this.subtotalLabel,
    required this.discountOptionalLabel,
    required this.totalLabel,
    required this.completeSale,
    required this.receiptTitle,
    required this.copyLabel,
    required this.receiptCopied,
    required this.close,
    required this.salesEmptyTitle,
    required this.salesEmptyBody,
    required this.validationCartEmpty,
    required this.validationDebtCustomerRequired,
    required this.validationMixedMismatchTemplate,
    required this.statusCompleted,
    required this.statusPartiallyReturned,
    required this.statusReturned,
    required this.salesCountTemplate,
    required this.priceLabel,
    required this.navExpenses,
    required this.expenseAddTitle,
    required this.expensesEmptyTitle,
    required this.expensesEmptyBody,
    required this.expenseCategoryLabel,
    required this.catRent,
    required this.catTransport,
    required this.catSalary,
    required this.catAds,
    required this.catElectricity,
    required this.catInternet,
    required this.catOther,
    required this.periodDay,
    required this.periodWeek,
    required this.periodMonth,
    required this.totalExpenseLabel,
    required this.expensesCountTemplate,
    required this.dateLabel,
    required this.deleteExpenseTitle,
    required this.deleteExpenseBody,
    required this.validationCategoryRequired,
    required this.navReports,
    required this.grossProfitLabel,
    required this.netProfitLabel,
    required this.averageCheckLabel,
    required this.periodCustom,
    required this.languageLabel,
    required this.languageUz,
    required this.languageRu,
    required this.changePinTitle,
    required this.pinCurrentSubtitle,
    required this.pinChanged,
    required this.logoutConfirmBody,
    required this.proPlanTitle,
    required this.proActiveLabel,
    required this.proExpiresLabel,
    required this.proDaysTemplate,
    required this.proFeatureVoice,
    required this.proFeatureAi,
    required this.proFeatureOcr,
    required this.proFeatureReports,
    required this.proCheckoutAction,
    required this.paymentPendingTitle,
    required this.paymentPendingBody,
    required this.paymentSuccess,
    required this.paymentFailedLabel,
    required this.checkStatusAction,
    required this.checkoutUnavailable,
    required this.notifDueSoonLabel,
    required this.notificationsEmptyTitle,
    required this.notificationsEmptyBody,
    required this.planScreenTitle,
    required this.planFreeName,
    required this.planStandardName,
    required this.planProName,
    required this.planCurrentLabel,
    required this.planFeatureBasic,
    required this.planFeatureSales,
    required this.planFeatureInventory,
    required this.planIncludesStandard,
    required this.planPriceTemplate,
    required this.planActiveLabel,
    required this.planActivateAction,
    required this.planUpgradeProAction,
    required this.choosePaymentTitle,
    required this.payWithPayme,
    required this.payWithClick,
    required this.planLockedTitle,
    required this.planLockedBody,
    required this.planLockedAction,
    required this.planActivatedTemplate,
    required this.bannerStandardTitle,
    required this.bannerStandardBody,
    required this.themeTitle,
    required this.themeSystem,
    required this.themeLight,
    required this.themeDark,
    required this.calculatorTitle,
    required this.calcError,
    required this.currencyTitle,
    required this.currencySource,
    required this.currencyUpdatedTemplate,
    required this.currencyEmpty,
    required this.supportTitle,
    required this.supportBody,
    required this.supportCall,
    required this.supportTelegram,
    required this.supportEmail,
    required this.supportHours,
    required this.guidesTitle,
    required this.guidesEmpty,
    required this.referralTitle,
    required this.referralBodyTemplate,
    required this.referralCodeLabel,
    required this.referralCopy,
    required this.referralCopied,
    required this.referralShare,
    required this.referralShareTemplate,
    required this.referralInvited,
    required this.referralPaying,
    required this.referralEarned,
    required this.referralFieldLabel,
    required this.bonusTitle,
    required this.bonusBalanceLabel,
    required this.bonusHistoryTitle,
    required this.bonusEmpty,
    required this.bonusFromTemplate,
    required this.bonusReversal,
    required this.linkOpenFailed,
    required this.darkModeTitle,
    required this.bonusPayPlan,
    required this.bonusWithdraw,
    required this.bonusPlanSheetTitle,
    required this.payWithBonus,
    required this.bonusNotEnough,
    required this.withdrawTitle,
    required this.withdrawAmountLabel,
    required this.withdrawCardLabel,
    required this.withdrawHolderLabel,
    required this.withdrawSubmit,
    required this.withdrawMinTemplate,
    required this.withdrawAllAction,
    required this.withdrawSentTitle,
    required this.withdrawSentBody,
    required this.withdrawalsHistoryTitle,
    required this.withdrawStatusPending,
    required this.withdrawStatusPaid,
    required this.withdrawStatusRejected,
    required this.validationCardInvalid,
    required this.validationAmountRequired,
    required this.bonusPlanPayment,
    required this.bonusWithdrawal,
    required this.bonusWithdrawalRefund,
    required this.blockedTitle,
    required this.blockedBody,
    required this.blockedReasonLabel,
    required this.markAllRead,
    required this.alertsTitle,
    required this.announcementsTitle,
    required this.alertDebtOverdueTemplate,
    required this.alertDebtDueSoonTemplate,
    required this.alertOutOfStockTemplate,
    required this.alertLowStockTemplate,
    required this.alertSubscriptionTemplate,
    required this.scanTitle,
    required this.scanHint,
    required this.scanProductNotFound,
    required this.scanOutOfStock,
    required this.scanAddedTemplate,
    required this.scanButton,
    required this.torchLabel,
    required this.printAction,
    required this.printerTitle,
    required this.printerNone,
    required this.printerPairedHint,
    required this.printerPaper,
    required this.printerTest,
    required this.printerPrinted,
    required this.printerFailed,
    required this.printerPermission,
    required this.printerBluetoothOff,
    required this.printerNoDevices,
    required this.printerChange,
    required this.voiceTitle,
    required this.voiceIntro,
    required this.voiceExample,
    required this.voiceListening,
    required this.voiceProcessing,
    required this.voiceTypeHint,
    required this.voiceSend,
    required this.voiceConfirm,
    required this.voiceDone,
    required this.voiceChooseCustomer,
    required this.voiceChooseProduct,
    required this.voiceProTitle,
    required this.voiceProBody,
    required this.proUpgradeAction,
    required this.voiceUnavailable,
    required this.voiceTalkAgain,
    required this.reportsProRequired,
    required this.ocrTitle,
    required this.ocrIntro,
    required this.ocrCamera,
    required this.ocrGallery,
    required this.ocrAnalyzing,
    required this.ocrReviewHint,
    required this.ocrUncertain,
    required this.ocrExisting,
    required this.ocrImportAction,
    required this.ocrNothingFound,
    required this.ocrImportedTemplate,
    required this.ocrSelectedTemplate,
    required this.ocrProBody,
    required this.ocrTryAgain,
  });

  final String localeCode;

  final String appName;
  final String slogan;

  final String onboardingTitle1;
  final String onboardingBody1;
  final String onboardingTitle2;
  final String onboardingBody2;
  final String onboardingTitle3;
  final String onboardingBody3;

  final String next;
  final String start;
  final String skip;

  final String greeting;
  final String notifications;

  final String statSales;
  final String statProfit;
  final String statDebtGiven;
  final String statDebtReturned;

  final String quickSale;
  final String quickDebt;
  final String quickPayment;
  final String quickStockIn;

  final String attentionNeeded;
  final String overdueDebtsTemplate;
  final String lowStockTemplate;
  final String view;
  final String viewInventory;

  final String todayTitle;
  final String todaySummaryTemplate;

  final String navHome;
  final String navCustomers;
  final String navDebts;
  final String navInventory;
  final String navSettings;

  final String proTitle;
  final String proBody;
  final String proAction;

  final String comingSoonTitle;
  final String comingSoonBody;

  final String cancel;
  final String confirm;
  final String save;
  final String searchHint;
  final String logout;

  // —— Auth: telefon raqami (TZ 4, 37.1)
  final String authTitle;
  final String authSubtitle;
  final String phoneLabel;
  final String phoneHint;
  final String sendSmsCode;
  final String orDivider;
  final String continueWithGoogle;

  // —— Auth: SMS tasdiqlash (TZ 6)
  final String otpTitle;
  final String otpSubtitle;
  final String otpResend;
  final String otpResendTemplate;
  final String back;
  final String continueLabel;

  // —— Auth: profil (TZ 5)
  final String profileTitle;
  final String profileSubtitle;
  final String nameLabel;
  final String nameHint;
  final String shopNameLabel;
  final String shopNameHint;
  final String businessTypeQuestion;
  final String businessClothes;
  final String businessFood;
  final String businessShoes;
  final String businessAppliances;
  final String businessOther;

  // —— Auth: PIN (TZ 7, 32, 33)
  final String pinCreateTitle;
  final String pinCreateSubtitle;
  final String pinConfirmTitle;
  final String pinConfirmSubtitle;
  final String pinRemember;
  final String pinMismatch;
  final String pinUnlockTitle;
  final String pinUnlockSubtitle;
  final String pinForgot;

  // —— Xatoliklar va validatsiya
  final String errorNetwork;
  final String errorUnknown;
  final String validationPhoneInvalid;
  final String validationNameRequired;
  final String validationOtpInvalid;

  // —— Mijozlar (TZ 9–10)
  final String customerAddTitle;
  final String customerEditTitle;
  final String filterAll;
  final String filterDebtors;
  final String filterClean;
  final String customersEmptyTitle;
  final String customersEmptyBody;
  final String searchEmptyTitle;
  final String searchEmptyBody;
  final String phoneOptionalLabel;
  final String addressLabel;
  final String addressHint;
  final String noteLabel;
  final String noteHint;
  final String balanceLabel;
  final String customerDebtLabel;
  final String noDebtLabel;
  final String historyTitle;
  final String historyEmptyTitle;
  final String historyEmptyBody;
  final String acceptPaymentTitle;
  final String amountLabel;
  final String payCash;
  final String payCard;
  final String validationAmountInvalid;

  /// To'lov qoldiqdan oshganda: `{max}` — ruxsat etilgan maksimal summa.
  final String validationAmountExceedsTemplate;
  final String edit;
  final String delete;
  final String deleteCustomerTitle;
  final String deleteCustomerBody;
  final String retry;
  final String historyDebt;
  final String historyPayment;
  final String historySale;
  final String overdueLabel;

  // —— Qarz daftari (TZ 7)
  final String debtAddTitle;
  final String filterOpen;
  final String filterOverdue;
  final String filterPaid;
  final String totalOutstanding;
  final String overdueAmountLabel;
  final String debtorsCountTemplate;
  final String debtsEmptyTitle;
  final String debtsEmptyBody;
  final String customerLabel;
  final String selectCustomerTitle;
  final String validationCustomerRequired;
  final String dueDateOptionalLabel;
  final String dueDateShort;
  final String paidLabel;
  final String remainingLabel;
  final String statusOpen;
  final String statusPartial;
  final String statusPaid;
  final String paymentsTitle;
  final String paymentsEmptyTitle;
  final String deleteDebtTitle;
  final String deleteDebtBody;
  final String clearLabel;

  // —— Ombor (TZ 11–12)
  final String productAddTitle;
  final String productEditTitle;
  final String filterLowStock;
  final String filterOutOfStock;
  final String productsEmptyTitle;
  final String productsEmptyBody;
  final String productNameLabel;
  final String productNameHint;
  final String categoryLabel;
  final String categoryHint;
  final String barcodeLabel;
  final String unitLabel;
  final String buyPriceLabel;
  final String sellPriceLabel;
  final String initialStockLabel;
  final String minStockLabel;
  final String marginLabel;
  final String stockLabel;
  final String stockOutTitle;
  final String qtyLabel;
  final String updateBuyPriceLabel;
  final String movementsTitle;
  final String movementsEmptyTitle;
  final String deleteProductTitle;
  final String deleteProductBody;
  final String validationProductNameRequired;
  final String validationSellPriceRequired;
  final String stockValueLabel;
  final String productsCountTemplate;
  final String adjustLabel;
  final String returnLabel;

  // —— Savdo (TZ 6, 16, 27)
  final String saleNewTitle;
  final String salesHistoryTitle;
  final String cartTitle;
  final String addProductLabel;
  final String selectProductTitle;
  final String quickAddProductTitle;
  final String payDebtLabel;
  final String payMixed;
  final String paymentMethodLabel;
  final String subtotalLabel;
  final String discountOptionalLabel;
  final String totalLabel;
  final String completeSale;
  final String receiptTitle;
  final String copyLabel;
  final String receiptCopied;
  final String close;
  final String salesEmptyTitle;
  final String salesEmptyBody;
  final String validationCartEmpty;
  final String validationDebtCustomerRequired;
  final String validationMixedMismatchTemplate;
  final String statusCompleted;
  final String statusPartiallyReturned;
  final String statusReturned;
  final String salesCountTemplate;
  final String priceLabel;

  // —— Xarajatlar (TZ 14)
  final String navExpenses;
  final String expenseAddTitle;
  final String expensesEmptyTitle;
  final String expensesEmptyBody;
  final String expenseCategoryLabel;
  final String catRent;
  final String catTransport;
  final String catSalary;
  final String catAds;
  final String catElectricity;
  final String catInternet;
  final String catOther;
  final String periodDay;
  final String periodWeek;
  final String periodMonth;
  final String totalExpenseLabel;
  final String expensesCountTemplate;
  final String dateLabel;
  final String deleteExpenseTitle;
  final String deleteExpenseBody;
  final String validationCategoryRequired;

  // —— Hisobot (TZ 17)
  final String navReports;
  final String grossProfitLabel;
  final String netProfitLabel;
  final String averageCheckLabel;
  final String periodCustom;

  // —— Sozlamalar (TZ 26, 35)
  final String languageLabel;
  final String languageUz;
  final String languageRu;
  final String changePinTitle;
  final String pinCurrentSubtitle;
  final String pinChanged;
  final String logoutConfirmBody;

  // —— Pro tarif va checkout (TZ 31, 35, 36)
  final String proPlanTitle;
  final String proActiveLabel;
  final String proExpiresLabel;
  final String proDaysTemplate;
  final String proFeatureVoice;
  final String proFeatureAi;
  final String proFeatureOcr;
  final String proFeatureReports;
  final String proCheckoutAction;
  final String paymentPendingTitle;
  final String paymentPendingBody;
  final String paymentSuccess;
  final String paymentFailedLabel;
  final String checkStatusAction;
  final String checkoutUnavailable;

  // —— Bildirishnomalar (TZ 22)
  final String notifDueSoonLabel;
  final String notificationsEmptyTitle;
  final String notificationsEmptyBody;

  // —— Tariflar: Standart (savdo + ombor) va Pro (TZ 31, 35)
  final String planScreenTitle;
  final String planFreeName;
  final String planStandardName;
  final String planProName;
  final String planCurrentLabel;
  final String planFeatureBasic;
  final String planFeatureSales;
  final String planFeatureInventory;
  final String planIncludesStandard;
  final String planPriceTemplate;
  final String planActiveLabel;
  final String planActivateAction;
  final String planUpgradeProAction;
  final String choosePaymentTitle;
  final String payWithPayme;
  final String payWithClick;
  final String planLockedTitle;
  final String planLockedBody;
  final String planLockedAction;
  final String planActivatedTemplate;
  final String bannerStandardTitle;
  final String bannerStandardBody;

  // —— Sozlamalar bo'limlari: mavzu, kalkulyator, kurslar, yordam, referal, bonus
  final String themeTitle;
  final String themeSystem;
  final String themeLight;
  final String themeDark;
  final String calculatorTitle;
  final String calcError;
  final String currencyTitle;
  final String currencySource;
  final String currencyUpdatedTemplate;
  final String currencyEmpty;
  final String supportTitle;
  final String supportBody;
  final String supportCall;
  final String supportTelegram;
  final String supportEmail;
  final String supportHours;
  final String guidesTitle;
  final String guidesEmpty;
  final String referralTitle;
  final String referralBodyTemplate;
  final String referralCodeLabel;
  final String referralCopy;
  final String referralCopied;
  final String referralShare;
  final String referralShareTemplate;
  final String referralInvited;
  final String referralPaying;
  final String referralEarned;
  final String referralFieldLabel;
  final String bonusTitle;
  final String bonusBalanceLabel;
  final String bonusHistoryTitle;
  final String bonusEmpty;
  final String bonusFromTemplate;
  final String bonusReversal;
  final String linkOpenFailed;
  final String darkModeTitle;
  final String bonusPayPlan;
  final String bonusWithdraw;
  final String bonusPlanSheetTitle;
  final String payWithBonus;
  final String bonusNotEnough;
  final String withdrawTitle;
  final String withdrawAmountLabel;
  final String withdrawCardLabel;
  final String withdrawHolderLabel;
  final String withdrawSubmit;
  final String withdrawMinTemplate;
  final String withdrawAllAction;
  final String withdrawSentTitle;
  final String withdrawSentBody;
  final String withdrawalsHistoryTitle;
  final String withdrawStatusPending;
  final String withdrawStatusPaid;
  final String withdrawStatusRejected;
  final String validationCardInvalid;
  final String validationAmountRequired;
  final String bonusPlanPayment;
  final String bonusWithdrawal;
  final String bonusWithdrawalRefund;
  final String blockedTitle;
  final String blockedBody;
  final String blockedReasonLabel;
  final String markAllRead;
  final String alertsTitle;
  final String announcementsTitle;
  final String alertDebtOverdueTemplate;
  final String alertDebtDueSoonTemplate;
  final String alertOutOfStockTemplate;
  final String alertLowStockTemplate;
  final String alertSubscriptionTemplate;
  final String scanTitle;
  final String scanHint;
  final String scanProductNotFound;
  final String scanOutOfStock;
  final String scanAddedTemplate;
  final String scanButton;
  final String torchLabel;
  final String printAction;
  final String printerTitle;
  final String printerNone;
  final String printerPairedHint;
  final String printerPaper;
  final String printerTest;
  final String printerPrinted;
  final String printerFailed;
  final String printerPermission;
  final String printerBluetoothOff;
  final String printerNoDevices;
  final String printerChange;
  final String voiceTitle;
  final String voiceIntro;
  final String voiceExample;
  final String voiceListening;
  final String voiceProcessing;
  final String voiceTypeHint;
  final String voiceSend;
  final String voiceConfirm;
  final String voiceDone;
  final String voiceChooseCustomer;
  final String voiceChooseProduct;
  final String voiceProTitle;
  final String voiceProBody;
  final String proUpgradeAction;
  final String voiceUnavailable;
  final String voiceTalkAgain;
  final String reportsProRequired;
  final String ocrTitle;
  final String ocrIntro;
  final String ocrCamera;
  final String ocrGallery;
  final String ocrAnalyzing;
  final String ocrReviewHint;
  final String ocrUncertain;
  final String ocrExisting;
  final String ocrImportAction;
  final String ocrNothingFound;
  final String ocrImportedTemplate;
  final String ocrSelectedTemplate;
  final String ocrProBody;
  final String ocrTryAgain;

  String ocrImportedText(int customers, int debts) => ocrImportedTemplate
      .replaceAll('{customers}', customers.toString())
      .replaceAll('{debts}', debts.toString());

  String ocrSelectedText(int count, String total) => ocrSelectedTemplate
      .replaceAll('{count}', count.toString())
      .replaceAll('{total}', total);

  String scanAddedText(String name) => scanAddedTemplate.replaceAll('{name}', name);

  String alertText(
    String template, {
    String name = '',
    String amount = '',
    String date = '',
    String stock = '',
    String unit = '',
    String min = '',
    String plan = '',
    String days = '',
  }) =>
      template
          .replaceAll('{name}', name)
          .replaceAll('{amount}', amount)
          .replaceAll('{date}', date)
          .replaceAll('{stock}', stock)
          .replaceAll('{unit}', unit)
          .replaceAll('{min}', min)
          .replaceAll('{plan}', plan)
          .replaceAll('{days}', days);

  String withdrawMinText(String amount) =>
      withdrawMinTemplate.replaceAll('{amount}', amount);

  /// `{time}` o'rniga yangilanish vaqti qo'yiladi.
  String currencyUpdatedText(String time) =>
      currencyUpdatedTemplate.replaceAll('{time}', time);

  String referralBodyText(String percent) =>
      referralBodyTemplate.replaceAll('{percent}', percent);

  String referralShareText(String link, String code) =>
      referralShareTemplate.replaceAll('{link}', link).replaceAll('{code}', code);

  String bonusFromText(String name) =>
      bonusFromTemplate.replaceAll('{name}', name);

  /// Tarif narxi: `{price}` va `{days}` o'rniga qiymatlar qo'yiladi.
  String planPriceText(String price, int days) => planPriceTemplate
      .replaceAll('{price}', price)
      .replaceAll('{days}', days.toString());

  /// Tarif faollashgach: `{plan}` o'rniga tarif nomi qo'yiladi.
  String planActivatedText(String plan) =>
      planActivatedTemplate.replaceAll('{plan}', plan);

  /// Hisobot davri filtrlari — 0: bugun, 1: 7 kun, 2: 30 kun, 3: custom.
  List<String> get reportPeriods =>
      <String>[periodDay, periodWeek, periodMonth, periodCustom];

  /// Xarajat davri filtrlari — backend `period` bilan bir tartibda:
  /// day | week | month | all.
  List<String> get expensePeriods =>
      <String>[periodDay, periodWeek, periodMonth, filterAll];

  /// Backend `expenses.category` uchun tildan mustaqil kalitlar.
  static const List<String> expenseCategoryKeys = <String>[
    'rent',
    'transport',
    'salary',
    'ads',
    'electricity',
    'internet',
    'other',
  ];

  /// Kategoriya matnlari — `expenseCategoryKeys` bilan bir tartibda.
  List<String> get expenseCategories => <String>[
        catRent,
        catTransport,
        catSalary,
        catAds,
        catElectricity,
        catInternet,
        catOther,
      ];

  /// Backend `expenses.category` qiymatini foydalanuvchi matniga aylantiradi.
  String expenseCategoryText(String key) {
    return switch (key) {
      'rent' => catRent,
      'transport' => catTransport,
      'salary' => catSalary,
      'ads' => catAds,
      'electricity' => catElectricity,
      'internet' => catInternet,
      _ => catOther,
    };
  }

  /// `5 ta xarajat` — xarajatlar summary kartasi uchun.
  String expensesCountText(int count) =>
      expensesCountTemplate.replaceAll('{count}', count.toString());

  /// Ombor filtrlari — backend `filter` bilan bir tartibda:
  /// all | low_stock | out_of_stock.
  List<String> get productFilters =>
      <String>[filterAll, filterLowStock, filterOutOfStock];

  /// `12 ta mahsulot` — ombor summary kartasi uchun.
  String productsCountText(int count) =>
      productsCountTemplate.replaceAll('{count}', count.toString());

  /// Backend `stock_movements.type` qiymatini matnga aylantiradi.
  String movementTypeLabel(String type) {
    return switch (type) {
      'in' || 'initial' || 'purchase' => quickStockIn,
      'out' || 'loss' => stockOutTitle,
      'sale' => historySale,
      'return' || 'sale_return' => returnLabel,
      'adjust' || 'adjustment' || 'count' => adjustLabel,
      _ => type,
    };
  }

  /// Qarzlar ro'yxati filtrlari — backend `status` bilan bir tartibda:
  /// all | unpaid | overdue | paid.
  List<String> get debtFilters =>
      <String>[filterAll, filterOpen, filterOverdue, filterPaid];

  /// Backend `debts.status` qiymatini foydalanuvchi matniga aylantiradi.
  String debtStatusLabel(String status) {
    return switch (status) {
      'paid' => statusPaid,
      'partial' => statusPartial,
      _ => statusOpen,
    };
  }

  /// `5 ta qarzdor` — dashboard va qarzlar sarlavhasi uchun.
  String debtorsCountText(int count) =>
      debtorsCountTemplate.replaceAll('{count}', count.toString());

  /// Mijozlar ro'yxati filtrlari — backend `filter` bilan bir tartibda:
  /// all | debtors | clean.
  List<String> get customerFilters =>
      <String>[filterAll, filterDebtors, filterClean];

  /// To'lov usullari — backend `payment_method` bilan bir tartibda:
  /// cash | card.
  List<String> get payMethods => <String>[payCash, payCard];

  /// Savdo to'lov usullari — backend `sales.payment_method` bilan bir
  /// tartibda: cash | card | debt | mixed.
  static const List<String> saleMethodKeys = <String>[
    'cash',
    'card',
    'debt',
    'mixed',
  ];

  List<String> get saleMethodLabels =>
      <String>[payCash, payCard, payDebtLabel, payMixed];

  /// Savdo tarixi filtrlari: all + to'lov usullari.
  List<String> get saleFilters =>
      <String>[filterAll, payCash, payCard, payDebtLabel, payMixed];

  /// Backend `sales.payment_method` qiymatini matnga aylantiradi.
  String saleMethodLabel(String method) {
    return switch (method) {
      'card' => payCard,
      'debt' => payDebtLabel,
      'mixed' => payMixed,
      _ => payCash,
    };
  }

  /// Backend `sales.status` qiymatini matnga aylantiradi.
  String saleStatusLabel(String status) {
    return switch (status) {
      'returned' => statusReturned,
      'partially_returned' => statusPartiallyReturned,
      _ => statusCompleted,
    };
  }

  /// `5 ta savdo` — savdo tarixi summary kartasi uchun.
  String salesCountText(int count) =>
      salesCountTemplate.replaceAll('{count}', count.toString());

  /// Aralash to'lov xatosi: `{total}` o'rniga jami summa qo'yiladi.
  String mixedMismatchText(String total) =>
      validationMixedMismatchTemplate.replaceAll('{total}', total);

  /// To'lov qoldiqdan oshib ketganda: `{max}` o'rniga maksimal summa qo'yiladi.
  String amountExceedsText(String max) =>
      validationAmountExceedsTemplate.replaceAll('{max}', max);

  /// Pro obuna muddati: `{days}` o'rniga kunlar soni qo'yiladi.
  String proDaysText(int days) =>
      proDaysTemplate.replaceAll('{days}', days.toString());

  /// `Qayta yuborish (01:23)` — [seconds] soniyadan mm:ss yasaladi.
  String otpResendIn(int seconds) {
    final String minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final String rest = (seconds % 60).toString().padLeft(2, '0');
    return otpResendTemplate.replaceAll('{timer}', '$minutes:$rest');
  }

  /// Savdo turi chiplari — ro'yxatdan o'tish ekrani uchun.
  List<String> get businessTypes => <String>[
        businessClothes,
        businessFood,
        businessShoes,
        businessAppliances,
        businessOther,
      ];

  /// Backend `business_type` uchun tildan mustaqil kalitlar.
  static const List<String> businessTypeKeys = <String>[
    'clothes',
    'food',
    'shoes',
    'appliances',
    'other',
  ];

  String overdueDebts(int count) =>
      overdueDebtsTemplate.replaceAll('{count}', count.toString());

  String lowStock(int count) =>
      lowStockTemplate.replaceAll('{count}', count.toString());

  String todaySummary({
    required String sales,
    required String profit,
    required String expense,
  }) {
    return todaySummaryTemplate
        .replaceAll('{sales}', sales)
        .replaceAll('{profit}', profit)
        .replaceAll('{expense}', expense);
  }

  static const List<Locale> supportedLocales = <Locale>[
    Locale('uz'),
    Locale('ru'),
  ];

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ?? uz;
  }

  static const AppStrings uz = AppStrings(
    localeCode: 'uz',
    appName: 'BozorPro',
    slogan: "Daftaringiz endi telefoningizda!",
    onboardingTitle1: "Qog'oz daftarni unuting",
    onboardingBody1: 'Mijozlar, qarzlar va savdoni telefoningizda saqlang.',
    onboardingTitle2: 'Savdoni hisoblang',
    onboardingBody2: "Har bir savdo va to'lov avtomatik hisoblanadi.",
    onboardingTitle3: 'Biznesingizni nazorat qiling',
    onboardingBody3:
        "Bugungi savdo, foyda, qarzlar va omborni bir joyda ko'ring.",
    next: 'Keyingi',
    start: 'Boshlash',
    skip: "O'tkazib yuborish",
    greeting: 'Assalomu alaykum,',
    notifications: 'Bildirishnomalar',
    statSales: 'Bugungi savdo',
    statProfit: 'Bugungi foyda',
    statDebtGiven: 'Berilgan qarz',
    statDebtReturned: 'Qaytgan qarz',
    quickSale: 'Savdo',
    quickDebt: 'Qarz',
    quickPayment: "To'lov",
    quickStockIn: 'Kirim',
    attentionNeeded: "E'tibor berish kerak",
    overdueDebtsTemplate: "{count} ta mijozning qarzi muddati o'tgan",
    lowStockTemplate: '{count} ta mahsulot tugash arafasida',
    view: "Ko'rish",
    viewInventory: "Omborni ko'rish",
    todayTitle: "Bugun nima bo'ldi?",
    todaySummaryTemplate:
        '{sales} savdo, {profit} yalpi foyda, {expense} xarajat.',
    navHome: 'Bosh sahifa',
    navCustomers: 'Mijozlar',
    navDebts: 'Qarzlar',
    navInventory: 'Ombor',
    navSettings: 'Sozlamalar',
    proTitle: "Pro'ga o'ting",
    proBody: 'Ovozli boshqaruv, AI yordamchi va eski daftar importi.',
    proAction: 'Batafsil',
    comingSoonTitle: 'Tez orada',
    comingSoonBody: "Bu bo'lim keyingi vazifada to'ldiriladi.",
    cancel: 'Bekor qilish',
    confirm: 'Tasdiqlash',
    save: 'Saqlash',
    searchHint: 'Qidirish...',
    logout: 'Chiqish',
    authTitle: "Ro'yxatdan o'tish",
    authSubtitle: 'Telefon raqamingizni kiriting, SMS kod yuboramiz.',
    phoneLabel: 'Telefon raqami',
    phoneHint: '90 123 45 67',
    sendSmsCode: 'SMS kodni yuborish',
    orDivider: 'Yoki',
    continueWithGoogle: 'Google bilan davom etish',
    otpTitle: 'SMS kodi',
    otpSubtitle: 'Telefon raqamingizga yuborilgan kodni kiriting.',
    otpResend: 'Qayta yuborish',
    otpResendTemplate: 'Qayta yuborish ({timer})',
    back: 'Ortga',
    continueLabel: 'Davom etish',
    profileTitle: "Ma'lumotlaringiz",
    profileSubtitle: "Ism va do'kon nomini kiriting.",
    nameLabel: 'Ismingiz',
    nameHint: 'Abdulloh',
    shopNameLabel: "Do'kon nomi",
    shopNameHint: 'Bozor Market',
    businessTypeQuestion: 'Nima sotasiz?',
    businessClothes: 'Kiyim',
    businessFood: 'Oziq-ovqat',
    businessShoes: 'Poyabzal',
    businessAppliances: 'Maishiy texnika',
    businessOther: 'Boshqa',
    pinCreateTitle: "PIN kod o'rnating",
    pinCreateSubtitle: 'Ilovadan har safar foydalanish uchun PIN kod yarating.',
    pinConfirmTitle: 'PIN kodni tasdiqlang',
    pinConfirmSubtitle: 'Yaratgan PIN kodingizni qayta kiriting.',
    pinRemember: 'PIN kodni unutmang!',
    pinMismatch: 'PIN kodlar mos kelmadi. Qaytadan kiriting.',
    pinUnlockTitle: 'PIN kodni kiriting',
    pinUnlockSubtitle: 'Davom etish uchun PIN kodingizni kiriting.',
    pinForgot: 'PIN kodni unutdingizmi?',
    errorNetwork: "Internet aloqasi yo'q. Qayta urinib ko'ring.",
    errorUnknown: "Xatolik yuz berdi. Qayta urinib ko'ring.",
    validationPhoneInvalid: "Telefon raqami to'liq emas.",
    validationNameRequired: 'Ismingizni kiriting.',
    validationOtpInvalid: "Kod 6 xonali bo'lishi kerak.",
    customerAddTitle: 'Yangi mijoz',
    customerEditTitle: 'Mijozni tahrirlash',
    filterAll: 'Barchasi',
    filterDebtors: 'Qarzdorlar',
    filterClean: 'Qarzsiz',
    customersEmptyTitle: "Hozircha mijozlar yo'q",
    customersEmptyBody:
        "Birinchi mijozingizni qo'shing — qarz va to'lovlar shu yerda ko'rinadi.",
    searchEmptyTitle: 'Hech narsa topilmadi',
    searchEmptyBody: "Qidiruv yoki filtrni o'zgartirib ko'ring.",
    phoneOptionalLabel: 'Telefon raqami (ixtiyoriy)',
    addressLabel: 'Manzil',
    addressHint: "Chorsu bozori, 12-do'kon",
    noteLabel: 'Izoh',
    noteHint: "Qo'shimcha ma'lumot",
    balanceLabel: 'Balans',
    customerDebtLabel: 'Qarzi',
    noDebtLabel: "Qarzi yo'q",
    historyTitle: 'Tarix',
    historyEmptyTitle: "Tarix bo'sh",
    historyEmptyBody: "Qarz va to'lovlar shu yerda ko'rinadi.",
    acceptPaymentTitle: "To'lov qabul qilish",
    amountLabel: 'Summa',
    payCash: 'Naqd',
    payCard: 'Karta',
    validationAmountInvalid: "Miqdor 0 bo'lishi mumkin emas.",
    validationAmountExceedsTemplate:
        'Summa qoldiqdan oshmasligi kerak (maksimal {max}).',
    edit: 'Tahrirlash',
    delete: "O'chirish",
    deleteCustomerTitle: "Mijozni o'chirish",
    deleteCustomerBody:
        "Mijoz va uning tarixi o'chiriladi. Davom etasizmi?",
    retry: 'Qayta urinish',
    historyDebt: 'Qarz',
    historyPayment: "To'lov",
    historySale: 'Savdo',
    overdueLabel: "Muddati o'tgan",
    debtAddTitle: 'Yangi qarz',
    filterOpen: 'Ochiq',
    filterOverdue: "Muddati o'tgan",
    filterPaid: "To'langan",
    totalOutstanding: 'Jami qarzdorlik',
    overdueAmountLabel: "Muddati o'tgan qarz",
    debtorsCountTemplate: '{count} ta qarzdor',
    debtsEmptyTitle: "Qarzlar yo'q",
    debtsEmptyBody: "Qarz yozish uchun + tugmasini bosing.",
    customerLabel: 'Mijoz',
    selectCustomerTitle: 'Mijozni tanlang',
    validationCustomerRequired: 'Mijozni tanlang.',
    dueDateOptionalLabel: 'Qaytarish muddati (ixtiyoriy)',
    dueDateShort: 'Muddat',
    paidLabel: "To'landi",
    remainingLabel: 'Qoldiq',
    statusOpen: 'Ochiq',
    statusPartial: "Qisman to'langan",
    statusPaid: "To'langan",
    paymentsTitle: "To'lovlar",
    paymentsEmptyTitle: "Hali to'lov yo'q",
    deleteDebtTitle: "Qarzni o'chirish",
    deleteDebtBody:
        "Qarz yozuvi o'chiriladi va mijoz balansi qayta hisoblanadi. Davom etasizmi?",
    clearLabel: 'Tozalash',
    productAddTitle: 'Yangi mahsulot',
    productEditTitle: 'Mahsulotni tahrirlash',
    filterLowStock: 'Kam qoldiq',
    filterOutOfStock: 'Tugagan',
    productsEmptyTitle: "Mahsulotlar yo'q",
    productsEmptyBody: "Birinchi mahsulotingizni qo'shing.",
    productNameLabel: 'Mahsulot nomi',
    productNameHint: 'Futbolka',
    categoryLabel: 'Kategoriya (ixtiyoriy)',
    categoryHint: 'Kiyim',
    barcodeLabel: 'Barcode (ixtiyoriy)',
    unitLabel: "O'lchov birligi",
    buyPriceLabel: 'Tannarx (ixtiyoriy)',
    sellPriceLabel: 'Sotuv narxi',
    initialStockLabel: "Boshlang'ich qoldiq",
    minStockLabel: 'Minimal qoldiq',
    marginLabel: 'Marja',
    stockLabel: 'Qoldiq',
    stockOutTitle: 'Chiqim',
    qtyLabel: 'Miqdor',
    updateBuyPriceLabel: 'Tannarxni yangilash',
    movementsTitle: 'Harakatlar',
    movementsEmptyTitle: "Hali harakatlar yo'q",
    deleteProductTitle: "Mahsulotni o'chirish",
    deleteProductBody: "Mahsulot ro'yxatdan o'chiriladi. Davom etasizmi?",
    validationProductNameRequired: 'Mahsulot nomini kiriting.',
    validationSellPriceRequired: 'Sotuv narxini kiriting.',
    stockValueLabel: 'Ombor qiymati',
    productsCountTemplate: '{count} ta mahsulot',
    adjustLabel: 'Inventarizatsiya',
    returnLabel: 'Qaytarish',
    saleNewTitle: 'Yangi savdo',
    salesHistoryTitle: 'Savdo tarixi',
    cartTitle: 'Savat',
    addProductLabel: "Mahsulot qo'shish",
    selectProductTitle: 'Mahsulotni tanlang',
    quickAddProductTitle: "Tezkor mahsulot qo'shish",
    payDebtLabel: 'Qarzga',
    payMixed: 'Aralash',
    paymentMethodLabel: "To'lov turi",
    subtotalLabel: 'Oraliq jami',
    discountOptionalLabel: 'Chegirma (ixtiyoriy)',
    totalLabel: 'Jami',
    completeSale: 'Savdoni yakunlash',
    receiptTitle: 'Chek',
    copyLabel: 'Nusxalash',
    receiptCopied: 'Chek nusxalandi.',
    close: 'Yopish',
    salesEmptyTitle: "Savdolar yo'q",
    salesEmptyBody: 'Birinchi savdoni yozish uchun + tugmasini bosing.',
    validationCartEmpty: 'Kamida bitta mahsulot tanlang.',
    validationDebtCustomerRequired: 'Qarzga savdo uchun mijozni tanlang.',
    validationMixedMismatchTemplate:
        "To'lovlar yig'indisi {total} bo'lishi kerak.",
    statusCompleted: 'Yakunlangan',
    statusPartiallyReturned: 'Qisman qaytarilgan',
    statusReturned: 'Qaytarilgan',
    salesCountTemplate: '{count} ta savdo',
    priceLabel: 'Narx',
    navExpenses: 'Xarajatlar',
    expenseAddTitle: 'Yangi xarajat',
    expensesEmptyTitle: "Xarajatlar yo'q",
    expensesEmptyBody: 'Birinchi xarajatni yozish uchun + tugmasini bosing.',
    expenseCategoryLabel: 'Kategoriya',
    catRent: 'Ijara',
    catTransport: 'Transport',
    catSalary: 'Maosh',
    catAds: 'Reklama',
    catElectricity: 'Elektr',
    catInternet: 'Internet',
    catOther: 'Boshqa',
    periodDay: 'Bugun',
    periodWeek: '7 kun',
    periodMonth: '30 kun',
    totalExpenseLabel: 'Jami xarajat',
    expensesCountTemplate: '{count} ta xarajat',
    dateLabel: 'Sana',
    deleteExpenseTitle: "Xarajatni o'chirish",
    deleteExpenseBody: "Xarajat yozuvi o'chiriladi. Davom etasizmi?",
    validationCategoryRequired: 'Kategoriyani tanlang.',
    navReports: 'Hisobot',
    grossProfitLabel: 'Yalpi foyda',
    netProfitLabel: 'Sof foyda',
    averageCheckLabel: "O'rtacha chek",
    periodCustom: 'Davr tanlash',
    languageLabel: 'Til',
    languageUz: "O'zbekcha",
    languageRu: 'Русский',
    changePinTitle: 'PIN kodni almashtirish',
    pinCurrentSubtitle: 'Joriy PIN kodingizni kiriting.',
    pinChanged: 'PIN kod yangilandi.',
    logoutConfirmBody: 'Hisobingizdan chiqmoqchimisiz?',
    proPlanTitle: 'Pro tarif',
    proActiveLabel: 'Pro faol',
    proExpiresLabel: 'Amal qilish muddati',
    proDaysTemplate: '{days} kunlik obuna',
    proFeatureVoice: 'Ovozli boshqaruv',
    proFeatureAi: 'AI biznes yordamchi',
    proFeatureOcr: "Eski daftarni OCR orqali ko'chirish",
    proFeatureReports: 'Kengaytirilgan hisobot va backup',
    proCheckoutAction: "To'lovga o'tish",
    paymentPendingTitle: "To'lov kutilmoqda",
    paymentPendingBody:
        "To'lovni yakunlang — holat avtomatik yangilanadi.",
    paymentSuccess: 'Pro faollashtirildi!',
    paymentFailedLabel: "To'lov amalga oshmadi. Qayta urinib ko'ring.",
    checkStatusAction: 'Holatni tekshirish',
    checkoutUnavailable: "To'lov provayderi hali sozlanmagan.",
    notifDueSoonLabel: 'Muddati yaqinlashmoqda',
    notificationsEmptyTitle: "Bildirishnomalar yo'q",
    notificationsEmptyBody:
        "Muddati o'tgan qarzlar va kam qolgan mahsulotlar shu yerda ko'rinadi.",
    planScreenTitle: 'Tariflar',
    planFreeName: 'Bepul',
    planStandardName: 'Standart',
    planProName: 'Pro',
    planCurrentLabel: 'Joriy tarif',
    planFeatureBasic: 'Mijozlar, qarz daftari va xarajatlar',
    planFeatureSales: "Savdo bo'limi",
    planFeatureInventory: "Ombor bo'limi",
    planIncludesStandard: 'Standart tarifdagi barcha imkoniyatlar',
    planPriceTemplate: "{price} / {days} kun",
    planActiveLabel: 'Faol',
    planActivateAction: 'Faollashtirish',
    planUpgradeProAction: "Pro'ga o'tish",
    choosePaymentTitle: "To'lov usulini tanlang",
    payWithPayme: "Payme orqali to'lash",
    payWithClick: "Click orqali to'lash",
    planLockedTitle: "Bu bo'lim yopiq",
    planLockedBody:
        "Savdo va ombor bo'limlaridan foydalanish uchun Standart yoki Pro tarifni faollashtiring.",
    planLockedAction: "Tariflarni ko'rish",
    planActivatedTemplate: '{plan} tarifi faollashtirildi!',
    bannerStandardTitle: "Savdo va omborni yoqing",
    bannerStandardBody: "Standart tarif — oyiga atigi 12 000 so'm.",
    themeTitle: "Mavzu",
    themeSystem: "Tizim bo'yicha",
    themeLight: "Yorug'",
    themeDark: "Qorong'u",
    calculatorTitle: "Kalkulyator",
    calcError: "Xato",
    currencyTitle: "Valyuta kurslari",
    currencySource: "Manba: Markaziy bank (cbu.uz)",
    currencyUpdatedTemplate: "Yangilangan: {time}",
    currencyEmpty: "Kurslarni yuklab bo'lmadi.",
    supportTitle: "Qo'llab-quvvatlash",
    supportBody: "Savollaringiz yoki muammo bo'lsa, biz bilan bog'laning.",
    supportCall: "Qo'ng'iroq qilish",
    supportTelegram: "Telegram orqali yozish",
    supportEmail: "Email yuborish",
    supportHours: "Ish vaqti",
    guidesTitle: "Qo'llanma videolar",
    guidesEmpty: "Videolar hozircha yo'q.",
    referralTitle: "Do'st taklif qilish",
    referralBodyTemplate: "Do'stingiz sizning havolangiz orqali kirib to'lov qilsa, uning har bir to'lovidan {percent}% bonus olasiz.",
    referralCodeLabel: "Sizning referal kodingiz",
    referralCopy: "Nusxa olish",
    referralCopied: "Nusxa olindi",
    referralShare: "Telegram orqali ulashish",
    referralShareTemplate: "BozorPro — bozorchi uchun raqamli daftar. Ro'yxatdan o'ting: {link} (referal kod: {code})",
    referralInvited: "Taklif qilinganlar",
    referralPaying: "To'lov qilganlar",
    referralEarned: "Jami ishlangan bonus",
    referralFieldLabel: "Referal kod (ixtiyoriy)",
    bonusTitle: "Bonuslar balansi",
    bonusBalanceLabel: "Joriy balans",
    bonusHistoryTitle: "Bonuslar tarixi",
    bonusEmpty: "Hali bonus yo'q. Do'stlaringizni taklif qiling!",
    bonusFromTemplate: "{name} to'lovidan",
    bonusReversal: "Bonus qaytarildi (to'lov bekor qilindi)",
    linkOpenFailed: "Havolani ochib bo'lmadi.",
    darkModeTitle: "Qorong'u rejim",
    bonusPayPlan: "Tarifga to'lash",
    bonusWithdraw: "Pulni yechib olish",
    bonusPlanSheetTitle: "Tarifni bonus bilan to'lash",
    payWithBonus: "Bonus balansi bilan to'lash",
    bonusNotEnough: "Bonus yetarli emas",
    withdrawTitle: "Pulni yechib olish",
    withdrawAmountLabel: "Yechib olinadigan summa",
    withdrawCardLabel: "Plastik karta raqami",
    withdrawHolderLabel: "Karta egasi (ixtiyoriy)",
    withdrawSubmit: "Adminga yuborish",
    withdrawMinTemplate: "Minimal summa: {amount}",
    withdrawAllAction: "Hammasi",
    withdrawSentTitle: "So'rov adminga yuborildi",
    withdrawSentBody: "Admin tekshirib, pulni kartangizga o'tkazadi. Holatni shu yerdan kuzating.",
    withdrawalsHistoryTitle: "Yechib olish so'rovlari",
    withdrawStatusPending: "Kutilmoqda",
    withdrawStatusPaid: "To'landi",
    withdrawStatusRejected: "Rad etildi",
    validationCardInvalid: "Karta raqami 16 xonali bo'lishi kerak.",
    validationAmountRequired: "Summani kiriting.",
    bonusPlanPayment: "Tarif to'lovi",
    bonusWithdrawal: "Yechib olish so'rovi",
    bonusWithdrawalRefund: "So'rov rad etildi — summa qaytdi",
    blockedTitle: "Hisobingiz bloklangan",
    blockedBody: "Hisobingiz administrator tomonidan bloklandi. Savollaringiz bo'lsa, qo'llab-quvvatlashga murojaat qiling.",
    blockedReasonLabel: "Sabab",
    markAllRead: "Hammasini o'qilgan deb belgilash",
    alertsTitle: "Ogohlantirishlar",
    announcementsTitle: "Xabarlar",
    alertDebtOverdueTemplate: "{name}: muddati o'tgan qarz — {amount}",
    alertDebtDueSoonTemplate: "{name}: {amount} qarz muddati {date} da tugaydi",
    alertOutOfStockTemplate: "{name} — omborda qolmadi",
    alertLowStockTemplate: "{name}: qoldiq {stock} {unit} (minimal {min})",
    alertSubscriptionTemplate: "{plan} tarifingiz {days} kundan keyin tugaydi",
    scanTitle: "Barcode skanerlash",
    scanHint: "Barcode'ni kamera ramkasiga tushiring",
    scanProductNotFound: "Mahsulot topilmadi",
    scanOutOfStock: "Omborda qolmagan",
    scanAddedTemplate: "Savatga qo'shildi: {name}",
    scanButton: "Skanerlash",
    torchLabel: "Chiroq",
    printAction: "Chop etish",
    printerTitle: "Chek printeri (Bluetooth)",
    printerNone: "Printer tanlanmagan",
    printerPairedHint: "Avval telefon Bluetooth sozlamalarida printerni ulang (juftlang), so'ng shu yerdan tanlang.",
    printerPaper: "Qog'oz kengligi",
    printerTest: "Sinov cheki",
    printerPrinted: "Chek chop etildi",
    printerFailed: "Chop etib bo'lmadi. Printer yoqilgani va juftlangani tekshiring.",
    printerPermission: "Bluetooth ruxsati kerak.",
    printerBluetoothOff: "Bluetooth o'chiq. Uni yoqing.",
    printerNoDevices: "Juftlangan printer topilmadi.",
    printerChange: "Printerni o'zgartirish",
    voiceTitle: "Ovozli boshqaruv",
    voiceIntro: "Mikrofonni bosing va buyruq ayting",
    voiceExample: "Masalan: \"Ali akaga 150 ming qarz yoz\"",
    voiceListening: "Eshityapman…",
    voiceProcessing: "Tahlil qilinmoqda…",
    voiceTypeHint: "Yoki buyruqni yozing",
    voiceSend: "Yuborish",
    voiceConfirm: "Tasdiqlash",
    voiceDone: "Bajarildi",
    voiceChooseCustomer: "Mijozni tanlang",
    voiceChooseProduct: "Mahsulotni tanlang",
    voiceProTitle: "Pro funksiya",
    voiceProBody: "Ovozli boshqaruv va AI yordamchi Pro tarifda ishlaydi.",
    proUpgradeAction: "Pro'ga o'tish",
    voiceUnavailable: "Ovozni taniy olmadi. Buyruqni yozib yuboring.",
    voiceTalkAgain: "Qayta gapirish",
    reportsProRequired: "30 kunlik va ixtiyoriy oraliq hisobot Pro tarifida ochiladi.",
    ocrTitle: "Eski daftarni ko'chirish",
    ocrIntro: "Daftar sahifasini suratga oling — mijozlar va qarz summalari avtomatik ajratiladi. Import qilishdan oldin hammasini tekshirasiz.",
    ocrCamera: "Kamera",
    ocrGallery: "Galereya",
    ocrAnalyzing: "Daftar o'qilmoqda…",
    ocrReviewHint: "Ma'lumotlarni tekshiring: noto'g'rilarini tuzating yoki belgisini olib tashlang.",
    ocrUncertain: "Tekshirish kerak",
    ocrExisting: "Mavjud mijoz",
    ocrImportAction: "Import qilish",
    ocrNothingFound: "Hech narsa topilmadi. Rasmni aniqroq oling.",
    ocrImportedTemplate: "{customers} ta yangi mijoz va {debts} ta qarz qo'shildi",
    ocrSelectedTemplate: "{count} ta qator · {total}",
    ocrProBody: "Eski daftarni ko'chirish Pro tarifda ishlaydi.",
    ocrTryAgain: "Boshqa rasm",
  );

  static const AppStrings ru = AppStrings(
    localeCode: 'ru',
    appName: 'BozorPro',
    slogan: 'Ваша тетрадь теперь в телефоне!',
    onboardingTitle1: 'Забудьте о бумажной тетради',
    onboardingBody1: 'Храните клиентов, долги и продажи в телефоне.',
    onboardingTitle2: 'Считайте продажи',
    onboardingBody2: 'Каждая продажа и платёж считаются автоматически.',
    onboardingTitle3: 'Контролируйте свой бизнес',
    onboardingBody3:
        'Продажи, прибыль, долги и склад — всё в одном месте.',
    next: 'Далее',
    start: 'Начать',
    skip: 'Пропустить',
    greeting: 'Здравствуйте,',
    notifications: 'Уведомления',
    statSales: 'Продажи за день',
    statProfit: 'Прибыль за день',
    statDebtGiven: 'Выдано в долг',
    statDebtReturned: 'Возвращено',
    quickSale: 'Продажа',
    quickDebt: 'Долг',
    quickPayment: 'Платёж',
    quickStockIn: 'Приём',
    attentionNeeded: 'Требует внимания',
    overdueDebtsTemplate: 'У {count} клиентов просрочен долг',
    lowStockTemplate: '{count} товаров заканчиваются',
    view: 'Смотреть',
    viewInventory: 'Открыть склад',
    todayTitle: 'Что было сегодня?',
    todaySummaryTemplate:
        '{sales} продаж, {profit} валовой прибыли, {expense} расходов.',
    navHome: 'Главная',
    navCustomers: 'Клиенты',
    navDebts: 'Долги',
    navInventory: 'Склад',
    navSettings: 'Настройки',
    proTitle: 'Перейти на Pro',
    proBody: 'Голосовое управление, AI-помощник и импорт старой тетради.',
    proAction: 'Подробнее',
    comingSoonTitle: 'Скоро',
    comingSoonBody: 'Этот раздел будет добавлен в следующей задаче.',
    cancel: 'Отмена',
    confirm: 'Подтвердить',
    save: 'Сохранить',
    searchHint: 'Поиск...',
    logout: 'Выйти',
    authTitle: 'Регистрация',
    authSubtitle: 'Введите номер телефона — мы отправим SMS-код.',
    phoneLabel: 'Номер телефона',
    phoneHint: '90 123 45 67',
    sendSmsCode: 'Отправить SMS-код',
    orDivider: 'Или',
    continueWithGoogle: 'Продолжить с Google',
    otpTitle: 'SMS-код',
    otpSubtitle: 'Введите код, отправленный на ваш номер.',
    otpResend: 'Отправить снова',
    otpResendTemplate: 'Отправить снова ({timer})',
    back: 'Назад',
    continueLabel: 'Продолжить',
    profileTitle: 'Ваши данные',
    profileSubtitle: 'Укажите имя и название магазина.',
    nameLabel: 'Ваше имя',
    nameHint: 'Абдулла',
    shopNameLabel: 'Название магазина',
    shopNameHint: 'Bozor Market',
    businessTypeQuestion: 'Что вы продаёте?',
    businessClothes: 'Одежда',
    businessFood: 'Продукты',
    businessShoes: 'Обувь',
    businessAppliances: 'Бытовая техника',
    businessOther: 'Другое',
    pinCreateTitle: 'Создайте PIN-код',
    pinCreateSubtitle: 'ПИН понадобится при каждом входе в приложение.',
    pinConfirmTitle: 'Подтвердите PIN-код',
    pinConfirmSubtitle: 'Введите созданный PIN-код ещё раз.',
    pinRemember: 'Не забудьте PIN-код!',
    pinMismatch: 'PIN-коды не совпадают. Попробуйте снова.',
    pinUnlockTitle: 'Введите PIN-код',
    pinUnlockSubtitle: 'Для продолжения введите свой PIN-код.',
    pinForgot: 'Забыли PIN-код?',
    errorNetwork: 'Нет интернет-соединения. Попробуйте снова.',
    errorUnknown: 'Произошла ошибка. Попробуйте снова.',
    validationPhoneInvalid: 'Номер телефона указан не полностью.',
    validationNameRequired: 'Введите ваше имя.',
    validationOtpInvalid: 'Код должен состоять из 6 цифр.',
    customerAddTitle: 'Новый клиент',
    customerEditTitle: 'Изменить клиента',
    filterAll: 'Все',
    filterDebtors: 'Должники',
    filterClean: 'Без долга',
    customersEmptyTitle: 'Пока нет клиентов',
    customersEmptyBody:
        'Добавьте первого клиента — долги и платежи появятся здесь.',
    searchEmptyTitle: 'Ничего не найдено',
    searchEmptyBody: 'Попробуйте изменить поиск или фильтр.',
    phoneOptionalLabel: 'Номер телефона (необязательно)',
    addressLabel: 'Адрес',
    addressHint: 'Рынок Чорсу, магазин 12',
    noteLabel: 'Заметка',
    noteHint: 'Дополнительная информация',
    balanceLabel: 'Баланс',
    customerDebtLabel: 'Долг',
    noDebtLabel: 'Без долга',
    historyTitle: 'История',
    historyEmptyTitle: 'История пуста',
    historyEmptyBody: 'Долги и платежи появятся здесь.',
    acceptPaymentTitle: 'Принять платёж',
    amountLabel: 'Сумма',
    payCash: 'Наличные',
    payCard: 'Карта',
    validationAmountInvalid: 'Сумма не может быть 0.',
    validationAmountExceedsTemplate:
        'Сумма не должна превышать остаток (максимум {max}).',
    edit: 'Изменить',
    delete: 'Удалить',
    deleteCustomerTitle: 'Удалить клиента',
    deleteCustomerBody:
        'Клиент и его история будут удалены. Продолжить?',
    retry: 'Повторить',
    historyDebt: 'Долг',
    historyPayment: 'Платёж',
    historySale: 'Продажа',
    overdueLabel: 'Просрочен',
    debtAddTitle: 'Новый долг',
    filterOpen: 'Открытые',
    filterOverdue: 'Просроченные',
    filterPaid: 'Оплаченные',
    totalOutstanding: 'Общий долг',
    overdueAmountLabel: 'Просроченный долг',
    debtorsCountTemplate: '{count} должников',
    debtsEmptyTitle: 'Долгов нет',
    debtsEmptyBody: 'Нажмите +, чтобы записать долг.',
    customerLabel: 'Клиент',
    selectCustomerTitle: 'Выберите клиента',
    validationCustomerRequired: 'Выберите клиента.',
    dueDateOptionalLabel: 'Срок возврата (необязательно)',
    dueDateShort: 'Срок',
    paidLabel: 'Оплачено',
    remainingLabel: 'Остаток',
    statusOpen: 'Открыт',
    statusPartial: 'Частично оплачен',
    statusPaid: 'Оплачен',
    paymentsTitle: 'Платежи',
    paymentsEmptyTitle: 'Платежей пока нет',
    deleteDebtTitle: 'Удалить долг',
    deleteDebtBody:
        'Запись долга будет удалена, баланс клиента пересчитан. Продолжить?',
    clearLabel: 'Очистить',
    productAddTitle: 'Новый товар',
    productEditTitle: 'Изменить товар',
    filterLowStock: 'Мало на складе',
    filterOutOfStock: 'Нет в наличии',
    productsEmptyTitle: 'Товаров нет',
    productsEmptyBody: 'Добавьте первый товар.',
    productNameLabel: 'Название товара',
    productNameHint: 'Футболка',
    categoryLabel: 'Категория (необязательно)',
    categoryHint: 'Одежда',
    barcodeLabel: 'Штрихкод (необязательно)',
    unitLabel: 'Единица измерения',
    buyPriceLabel: 'Себестоимость (необязательно)',
    sellPriceLabel: 'Цена продажи',
    initialStockLabel: 'Начальный остаток',
    minStockLabel: 'Минимальный остаток',
    marginLabel: 'Наценка',
    stockLabel: 'Остаток',
    stockOutTitle: 'Расход',
    qtyLabel: 'Количество',
    updateBuyPriceLabel: 'Обновить себестоимость',
    movementsTitle: 'Движения',
    movementsEmptyTitle: 'Движений пока нет',
    deleteProductTitle: 'Удалить товар',
    deleteProductBody: 'Товар будет удалён из списка. Продолжить?',
    validationProductNameRequired: 'Введите название товара.',
    validationSellPriceRequired: 'Укажите цену продажи.',
    stockValueLabel: 'Стоимость склада',
    productsCountTemplate: '{count} товаров',
    adjustLabel: 'Инвентаризация',
    returnLabel: 'Возврат',
    saleNewTitle: 'Новая продажа',
    salesHistoryTitle: 'История продаж',
    cartTitle: 'Корзина',
    addProductLabel: 'Добавить товар',
    selectProductTitle: 'Выберите товар',
    quickAddProductTitle: 'Быстрое добавление товара',
    payDebtLabel: 'В долг',
    payMixed: 'Смешанная',
    paymentMethodLabel: 'Способ оплаты',
    subtotalLabel: 'Промежуточный итог',
    discountOptionalLabel: 'Скидка (необязательно)',
    totalLabel: 'Итого',
    completeSale: 'Завершить продажу',
    receiptTitle: 'Чек',
    copyLabel: 'Копировать',
    receiptCopied: 'Чек скопирован.',
    close: 'Закрыть',
    salesEmptyTitle: 'Продаж пока нет',
    salesEmptyBody: 'Нажмите +, чтобы записать первую продажу.',
    validationCartEmpty: 'Выберите хотя бы один товар.',
    validationDebtCustomerRequired: 'Для продажи в долг выберите клиента.',
    validationMixedMismatchTemplate:
        'Сумма платежей должна быть равна {total}.',
    statusCompleted: 'Завершена',
    statusPartiallyReturned: 'Частично возвращена',
    statusReturned: 'Возвращена',
    salesCountTemplate: '{count} продаж',
    priceLabel: 'Цена',
    navExpenses: 'Расходы',
    expenseAddTitle: 'Новый расход',
    expensesEmptyTitle: 'Расходов нет',
    expensesEmptyBody: 'Нажмите +, чтобы записать первый расход.',
    expenseCategoryLabel: 'Категория',
    catRent: 'Аренда',
    catTransport: 'Транспорт',
    catSalary: 'Зарплата',
    catAds: 'Реклама',
    catElectricity: 'Электричество',
    catInternet: 'Интернет',
    catOther: 'Другое',
    periodDay: 'Сегодня',
    periodWeek: '7 дней',
    periodMonth: '30 дней',
    totalExpenseLabel: 'Всего расходов',
    expensesCountTemplate: '{count} расходов',
    dateLabel: 'Дата',
    deleteExpenseTitle: 'Удалить расход',
    deleteExpenseBody: 'Запись расхода будет удалена. Продолжить?',
    validationCategoryRequired: 'Выберите категорию.',
    navReports: 'Отчёт',
    grossProfitLabel: 'Валовая прибыль',
    netProfitLabel: 'Чистая прибыль',
    averageCheckLabel: 'Средний чек',
    periodCustom: 'Выбрать период',
    languageLabel: 'Язык',
    languageUz: "O'zbekcha",
    languageRu: 'Русский',
    changePinTitle: 'Сменить PIN-код',
    pinCurrentSubtitle: 'Введите текущий PIN-код.',
    pinChanged: 'PIN-код обновлён.',
    logoutConfirmBody: 'Выйти из аккаунта?',
    proPlanTitle: 'Тариф Pro',
    proActiveLabel: 'Pro активен',
    proExpiresLabel: 'Действует до',
    proDaysTemplate: 'Подписка на {days} дней',
    proFeatureVoice: 'Голосовое управление',
    proFeatureAi: 'AI бизнес-помощник',
    proFeatureOcr: 'Импорт старой тетради через OCR',
    proFeatureReports: 'Расширенные отчёты и резервное копирование',
    proCheckoutAction: 'Перейти к оплате',
    paymentPendingTitle: 'Ожидание оплаты',
    paymentPendingBody:
        'Завершите оплату — статус обновится автоматически.',
    paymentSuccess: 'Pro активирован!',
    paymentFailedLabel: 'Оплата не прошла. Попробуйте снова.',
    checkStatusAction: 'Проверить статус',
    checkoutUnavailable: 'Платёжный провайдер ещё не настроен.',
    notifDueSoonLabel: 'Срок приближается',
    notificationsEmptyTitle: 'Уведомлений нет',
    notificationsEmptyBody:
        'Просроченные долги и заканчивающиеся товары появятся здесь.',
    planScreenTitle: 'Тарифы',
    planFreeName: 'Бесплатный',
    planStandardName: 'Стандарт',
    planProName: 'Pro',
    planCurrentLabel: 'Текущий тариф',
    planFeatureBasic: 'Клиенты, долговая тетрадь и расходы',
    planFeatureSales: 'Раздел «Продажи»',
    planFeatureInventory: 'Раздел «Склад»',
    planIncludesStandard: 'Все возможности тарифа «Стандарт»',
    planPriceTemplate: '{price} / {days} дн.',
    planActiveLabel: 'Активен',
    planActivateAction: 'Активировать',
    planUpgradeProAction: 'Перейти на Pro',
    choosePaymentTitle: 'Выберите способ оплаты',
    payWithPayme: 'Оплатить через Payme',
    payWithClick: 'Оплатить через Click',
    planLockedTitle: 'Раздел закрыт',
    planLockedBody:
        'Чтобы пользоваться разделами «Продажи» и «Склад», активируйте тариф «Стандарт» или Pro.',
    planLockedAction: 'Посмотреть тарифы',
    planActivatedTemplate: 'Тариф «{plan}» активирован!',
    bannerStandardTitle: 'Подключите продажи и склад',
    bannerStandardBody: 'Тариф «Стандарт» — всего 12 000 сум в месяц.',
    themeTitle: "Тема",
    themeSystem: "Как в системе",
    themeLight: "Светлая",
    themeDark: "Тёмная",
    calculatorTitle: "Калькулятор",
    calcError: "Ошибка",
    currencyTitle: "Курсы валют",
    currencySource: "Источник: Центральный банк (cbu.uz)",
    currencyUpdatedTemplate: "Обновлено: {time}",
    currencyEmpty: "Не удалось загрузить курсы.",
    supportTitle: "Поддержка",
    supportBody: "Если есть вопросы или проблема — свяжитесь с нами.",
    supportCall: "Позвонить",
    supportTelegram: "Написать в Telegram",
    supportEmail: "Отправить email",
    supportHours: "Время работы",
    guidesTitle: "Видеоинструкции",
    guidesEmpty: "Видео пока нет.",
    referralTitle: "Пригласить друга",
    referralBodyTemplate: "Если друг зарегистрируется по вашей ссылке и оплатит тариф, вы получите {percent}% бонусом с каждой его оплаты.",
    referralCodeLabel: "Ваш реферальный код",
    referralCopy: "Копировать",
    referralCopied: "Скопировано",
    referralShare: "Поделиться в Telegram",
    referralShareTemplate: "BozorPro — цифровая тетрадь для торговцев. Регистрация: {link} (реферальный код: {code})",
    referralInvited: "Приглашено",
    referralPaying: "Оплатили",
    referralEarned: "Всего заработано бонусов",
    referralFieldLabel: "Реферальный код (необязательно)",
    bonusTitle: "Бонусный баланс",
    bonusBalanceLabel: "Текущий баланс",
    bonusHistoryTitle: "История бонусов",
    bonusEmpty: "Бонусов пока нет. Приглашайте друзей!",
    bonusFromTemplate: "С оплаты {name}",
    bonusReversal: "Бонус возвращён (оплата отменена)",
    linkOpenFailed: "Не удалось открыть ссылку.",
    darkModeTitle: "Тёмный режим",
    bonusPayPlan: "Оплатить тариф",
    bonusWithdraw: "Вывести деньги",
    bonusPlanSheetTitle: "Оплатить тариф бонусами",
    payWithBonus: "Оплатить бонусами",
    bonusNotEnough: "Недостаточно бонусов",
    withdrawTitle: "Вывод денег",
    withdrawAmountLabel: "Сумма вывода",
    withdrawCardLabel: "Номер банковской карты",
    withdrawHolderLabel: "Владелец карты (необязательно)",
    withdrawSubmit: "Отправить админу",
    withdrawMinTemplate: "Минимальная сумма: {amount}",
    withdrawAllAction: "Всё",
    withdrawSentTitle: "Заявка отправлена админу",
    withdrawSentBody: "Админ проверит и переведёт деньги на вашу карту. Статус виден здесь.",
    withdrawalsHistoryTitle: "Заявки на вывод",
    withdrawStatusPending: "Ожидает",
    withdrawStatusPaid: "Выплачено",
    withdrawStatusRejected: "Отклонено",
    validationCardInvalid: "Номер карты должен содержать 16 цифр.",
    validationAmountRequired: "Введите сумму.",
    bonusPlanPayment: "Оплата тарифа",
    bonusWithdrawal: "Заявка на вывод",
    bonusWithdrawalRefund: "Заявка отклонена — сумма возвращена",
    blockedTitle: "Ваш аккаунт заблокирован",
    blockedBody: "Ваш аккаунт заблокирован администратором. Если есть вопросы, обратитесь в поддержку.",
    blockedReasonLabel: "Причина",
    markAllRead: "Отметить всё прочитанным",
    alertsTitle: "Предупреждения",
    announcementsTitle: "Сообщения",
    alertDebtOverdueTemplate: "{name}: просроченный долг — {amount}",
    alertDebtDueSoonTemplate: "{name}: долг {amount} до {date}",
    alertOutOfStockTemplate: "{name} — закончился на складе",
    alertLowStockTemplate: "{name}: остаток {stock} {unit} (минимум {min})",
    alertSubscriptionTemplate: "Ваш тариф {plan} закончится через {days} дн.",
    scanTitle: "Сканирование штрихкода",
    scanHint: "Наведите камеру на штрихкод",
    scanProductNotFound: "Товар не найден",
    scanOutOfStock: "Нет на складе",
    scanAddedTemplate: "Добавлено в корзину: {name}",
    scanButton: "Сканировать",
    torchLabel: "Фонарик",
    printAction: "Печать",
    printerTitle: "Принтер чеков (Bluetooth)",
    printerNone: "Принтер не выбран",
    printerPairedHint: "Сначала подключите (сопрягите) принтер в настройках Bluetooth телефона, затем выберите его здесь.",
    printerPaper: "Ширина бумаги",
    printerTest: "Пробный чек",
    printerPrinted: "Чек напечатан",
    printerFailed: "Не удалось напечатать. Проверьте, что принтер включён и сопряжён.",
    printerPermission: "Нужно разрешение Bluetooth.",
    printerBluetoothOff: "Bluetooth выключен. Включите его.",
    printerNoDevices: "Сопряжённых принтеров не найдено.",
    printerChange: "Сменить принтер",
    voiceTitle: "Голосовое управление",
    voiceIntro: "Нажмите микрофон и скажите команду",
    voiceExample: "Например: «Запиши долг Али 150 тысяч»",
    voiceListening: "Слушаю…",
    voiceProcessing: "Анализирую…",
    voiceTypeHint: "Или введите команду",
    voiceSend: "Отправить",
    voiceConfirm: "Подтвердить",
    voiceDone: "Выполнено",
    voiceChooseCustomer: "Выберите клиента",
    voiceChooseProduct: "Выберите товар",
    voiceProTitle: "Функция Pro",
    voiceProBody: "Голосовое управление и AI-помощник доступны на тарифе Pro.",
    proUpgradeAction: "Перейти на Pro",
    voiceUnavailable: "Не удалось распознать речь. Введите команду текстом.",
    voiceTalkAgain: "Сказать снова",
    reportsProRequired: "Отчёты за 30 дней и за произвольный период доступны на тарифе Pro.",
    ocrTitle: "Перенос старой тетради",
    ocrIntro: "Сфотографируйте страницу тетради — клиенты и суммы долгов распознаются автоматически. Перед импортом вы всё проверите.",
    ocrCamera: "Камера",
    ocrGallery: "Галерея",
    ocrAnalyzing: "Читаю тетрадь…",
    ocrReviewHint: "Проверьте данные: исправьте ошибки или снимите отметку со строки.",
    ocrUncertain: "Нужно проверить",
    ocrExisting: "Существующий клиент",
    ocrImportAction: "Импортировать",
    ocrNothingFound: "Ничего не найдено. Сделайте снимок чётче.",
    ocrImportedTemplate: "Добавлено новых клиентов: {customers}, долгов: {debts}",
    ocrSelectedTemplate: "Строк: {count} · {total}",
    ocrProBody: "Перенос старой тетради доступен на тарифе Pro.",
    ocrTryAgain: "Другое фото",
  );
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppStrings.supportedLocales
        .any((Locale it) => it.languageCode == locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) async {
    return locale.languageCode == 'ru' ? AppStrings.ru : AppStrings.uz;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}

/// Qulaylik uchun: `context.s.navHome`.
extension AppStringsContext on BuildContext {
  AppStrings get s => AppStrings.of(this);
}
