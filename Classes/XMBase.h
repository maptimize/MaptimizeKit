//
//  XMBase.h
//  MaptimizeKit
//
//  Created by Oleg Shnitko on 5/20/10.
//  olegshnitko@gmail.com
//  
//  Copyright © 2010 Screen Customs s.r.o. All rights reserved.
//

#import "XMConfig.h"

#import "SCMemoryManagement.h"

#if !defined(XM_INLINE)
#  if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#    define XM_INLINE static inline
#  elif defined(__MWERKS__) || defined(__cplusplus)
#    define XM_INLINE static inline
#  elif defined(__GNUC__)
#    define XM_INLINE static __inline__
#  else
#    define XM_INLINE static    
#  endif
#endif

#if !defined(XM_EXTERN)
#    if defined(__cplusplus)
#      define XM_EXTERN extern "C"
#    else
#      define XM_EXTERN extern
#    endif
#endif