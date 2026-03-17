locals {
  # Application Insights - auto-wire connection string to web apps when AI is created by this module
  application_insights_connection_string = var.application_insights_enabled ? module.application_insights[0].connection_string : null
  # Default Application Insights app settings for proper configuration when AI is enabled
  application_insights_default_app_settings = var.application_insights_enabled ? {
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    APPLICATIONINSIGHTS_ENABLESQLQUERYCOLLECTION    = "disabled"
    ApplicationInsightsAgent_EXTENSION_VERSION      = "~3"
    DISABLE_APPINSIGHTS_SDK                         = "disabled"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    IGNORE_APPINSIGHTS_SDK                          = "disabled"
    InstrumentationEngine_EXTENSION_VERSION         = "disabled"
    SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
  } : {}
  # Default Application Insights sticky settings (slot settings) to keep AI config bound to each slot
  application_insights_default_sticky_settings = var.application_insights_enabled ? {
    application_insights = {
      app_setting_names = [
        "APPINSIGHTS_INSTRUMENTATIONKEY",
        "APPLICATIONINSIGHTS_CONNECTION_STRING",
        "APPINSIGHTS_PROFILERFEATURE_VERSION",
        "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
        "ApplicationInsightsAgent_EXTENSION_VERSION",
        "XDT_MicrosoftApplicationInsights_BaseExtensions",
        "DiagnosticServices_EXTENSION_VERSION",
        "InstrumentationEngine_EXTENSION_VERSION",
        "SnapshotDebugger_EXTENSION_VERSION",
        "XDT_MicrosoftApplicationInsights_Mode",
        "XDT_MicrosoftApplicationInsights_PreemptSdk",
        "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
        "XDT_MicrosoftApplicationInsightsJava",
        "XDT_MicrosoftApplicationInsights_NodeJS",
      ]
      connection_string_names = []
    }
  } : {}
  application_insights_key = var.application_insights_enabled ? module.application_insights[0].instrumentation_key : null
}
