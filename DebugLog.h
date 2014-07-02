//
//  DebugLog.h
//  NSLog-ing my way.
//
//  Sticktron 2014
//

#ifdef DEBUG

	// Default Prefix
	#ifndef DEBUG_PREFIX
		#define DEBUG_PREFIX @"[DebugLog] "
	#endif


	// Print styles

	// class::selector >> message
	#define DebugLog(s, ...) \
		NSLog(@"%@ %@::%@ >> %@", DEBUG_PREFIX, \
			NSStringFromClass([self class]), \
			NSStringFromSelector(_cmd), \
			[NSString stringWithFormat:(s), ##__VA_ARGS__] \
		)

	// class::selector
	#define DebugLog0 \
		NSLog(@"%@ %@::%@", DEBUG_PREFIX, \
			NSStringFromClass([self class]), \
			NSStringFromSelector(_cmd) \
		)

	// message
	#define DebugLogC(s, ...) \
		NSLog(@"%@ >> %@", DEBUG_PREFIX, \
			[NSString stringWithFormat:(s), ##__VA_ARGS__] \
		)

//	// filename:(line number) >> method signature >> message
//		#define DebugLogMore(s, ...) \
//			NSLog(@"%@ %s:(%d) >> %s >> %@", \
//			DEBUG_PREFIX, \
//			[[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
//			__LINE__, \
//			__PRETTY_FUNCTION__, \
//			[NSString stringWithFormat:(s), \
//			##__VA_ARGS__] \
//		)

#else

	// Ignore macros
	#define DebugLog(s, ...)
	#define DebugLog0
	#define DebugLogC(s, ...)
//	#define DebugLogMore(s, ...)

#endif



//#define UA_SHOW_VIEW_BORDERS YES
//#define UA_showDebugBorderForViewColor(view, color) if (UA_SHOW_VIEW_BORDERS) { view.layer.borderColor = color.CGColor; view.layer.borderWidth = 1.0; }
//#define UA_showDebugBorderForView(view) UA_showDebugBorderForViewColor(view, [UIColor colorWithWhite:0.0 alpha:0.25])
