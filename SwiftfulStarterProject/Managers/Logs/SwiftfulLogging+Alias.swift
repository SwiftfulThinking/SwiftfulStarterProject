//
//  SwiftfulLogging+Alias.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftfulLogging
import SwiftfulLoggingMixpanel // #feature: analytics
import SwiftfulLoggingFirebaseAnalytics // #feature: analytics
import SwiftfulLoggingFirebaseCrashlytics // #feature: analytics

typealias LogManager = SwiftfulLogging.LogManager
typealias LoggableEvent = SwiftfulLogging.LoggableEvent
typealias LogType = SwiftfulLogging.LogType
typealias LogService = SwiftfulLogging.LogService
typealias AnyLoggableEvent = SwiftfulLogging.AnyLoggableEvent
typealias ConsoleService = SwiftfulLogging.ConsoleService
typealias MixpanelService = SwiftfulLoggingMixpanel.MixpanelService // #feature: analytics
typealias FirebaseAnalyticsService = SwiftfulLoggingFirebaseAnalytics.FirebaseAnalyticsService // #feature: analytics
typealias FirebaseCrashlyticsService = SwiftfulLoggingFirebaseCrashlytics.FirebaseCrashlyticsService // #feature: analytics
