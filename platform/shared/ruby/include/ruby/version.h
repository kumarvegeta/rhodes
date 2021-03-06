/**********************************************************************

  ruby/version.h -

  $Author: akr $
  created at: Wed May 13 12:56:56 JST 2009

  Copyright (C) 1993-2009 Yukihiro Matsumoto
  Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
  Copyright (C) 2000  Information-technology Promotion Agency, Japan

**********************************************************************/

/*
 * This file contains only
 * - never-changable informations, and
 * - interfaces accessible from extension libraries.
 *
 * Never try to check RUBY_VERSION_CODE etc in extension libraries,
 * check the features with mkmf.rb instead.
 */

#ifndef RUBY_VERSION_H
#define RUBY_VERSION_H 1

/* The origin. */
#define RUBY_AUTHOR "Yukihiro Matsumoto"
#define RUBY_BIRTH_YEAR 1993
#define RUBY_BIRTH_MONTH 2
#define RUBY_BIRTH_DAY 24

#ifdef RUBY_EXTERN
#if defined(__cplusplus)
extern "C" {
#if 0
} /* satisfy cc-mode */
#endif
#endif
/*
 * Interfaces from extension libraries.
 *
 * Before using these infos, think thrice whether they are really
 * necessary or not, and if the answer was yes, think twice a week
 * later again.
 */
RUBY_EXTERN const char ruby_version[];
RUBY_EXTERN const char ruby_release_date[];
RUBY_EXTERN const char ruby_platform[];
RUBY_EXTERN const int  ruby_patchlevel;
RUBY_EXTERN const char ruby_description[];
RUBY_EXTERN const char ruby_copyright[];
RUBY_EXTERN const char ruby_engine[];
#if defined(__cplusplus)
#if 0
{ /* satisfy cc-mode */
#endif
}  /* extern "C" { */
#endif
#endif

#endif
