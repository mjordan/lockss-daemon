/*
 * $Id$
 */

/*

Copyright (c) 2001-2017 Board of Trustees of Leland Stanford Jr. University,
all rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
STANFORD UNIVERSITY BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of Stanford University shall not
be used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from Stanford University.

*/

package org.lockss.config;

import java.util.Iterator;
import java.util.List;

import org.lockss.config.Configuration.InvalidParam;

public class CurrentConfig {

  private CurrentConfig() {
    //can't be instantiated
  }

  /** Return current configuration, or an empty configuration if there is
   * no current configuration. */
  public static Configuration getCurrentConfig() {
    return ConfigManager.getCurrentConfig();
  }

  /** Static convenience method to get param from current configuration.
   */
  public static String getParam(String key) {
    Configuration cur = getCurrentConfig();
    if (cur == null) {
      return null;
    }
    return cur.get(key);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static String getParam(String key, String dfault) {
    Configuration cur = getCurrentConfig();
    if (cur == null) {
      return dfault;
    }
    return cur.get(key, dfault);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static boolean getBooleanParam(String key) throws InvalidParam {
    return getCurrentConfig().getBoolean(key);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static boolean getBooleanParam(String key, boolean dfault) {
    Configuration cur = getCurrentConfig();
    if (cur == null) {
      return dfault;
    }
    return cur.getBoolean(key, dfault);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static int getIntParam(String key) throws InvalidParam {
    return getCurrentConfig().getInt(key);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static int getIntParam(String key, int dfault) {
    Configuration cur = getCurrentConfig();
    if (cur == null) {
      return dfault;
    }
    return cur.getInt(key, dfault);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static long getLongParam(String key) throws InvalidParam {
    return getCurrentConfig().getLong(key);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static long getLongParam(String key, long dfault) {
    Configuration cur = getCurrentConfig();
    if (cur == null) {
      return dfault;
    }
    return cur.getLong(key, dfault);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static long getTimeIntervalParam(String key) throws InvalidParam {
    return getCurrentConfig().getTimeInterval(key);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static long getTimeIntervalParam(String key, long dfault) {
    Configuration cur = getCurrentConfig();
    if (cur == null) {
      return dfault;
    }
    return cur.getTimeInterval(key, dfault);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static double getDoubleParam(String key) throws InvalidParam {
    return getCurrentConfig().getDouble(key);
  }

  /** Static convenience method to get param from current configuration.
   */
  public static double getDoubleParam(String key, double dfault) {
    Configuration cur = getCurrentConfig();
    if (cur == null) {
      return dfault;
    }
    return cur.getDouble(key, dfault);
  }

  /** Static convenience method to get a <code>Configuration</code>
   * subtree from the current configuration.
   */
  public static Configuration paramConfigTree(String key) {
    return getCurrentConfig().getConfigTree(key);
  }

  /** Static convenience method to get key iterator from the
   * current configuration.
   */
  public static Iterator paramKeyIterator() {
    return getCurrentConfig().keyIterator();
  }

  /** Static convenience method to get a node iterator from the
   * current configuration.
   */
  public static Iterator paramNodeIterator(String key) {
    return getCurrentConfig().nodeIterator(key);
  }
  
  /** Static convenience method to get a list from the current
   * configuration.
   */
   public static List getList(String key) {
    Configuration cur = getCurrentConfig();
    if (cur == null) {
      return null;
    }
     return cur.getList(key);
   }

   /** Static convenience method to get a list from the current
    * configuration.
    */
   public static List getList(String key, List dfault) {
    Configuration cur = getCurrentConfig();
    if (cur == null) {
      return dfault;
    }
     return cur.getList(key, dfault);
   }

  /** If val is of the form "<code>@<i>param_name</i></code>", and
   * <i>param_name</i> is the name of a parameter set in the current
   * Configuration, return its value.  If it is not set, return
   * <i>dfault</i>.  If val is not of the form
   * "<code>@<i>param_name</i></code>" return it verbatim.
   * @param key any String value, possibly beginning with <code>@</code>.
   * @param dfault the default value to return if the named param is not set
   * @return a String
   */
   public static String getIndirect(String val, String dfault) {
    Configuration cur = getCurrentConfig();
    return cur.getIndirect(val, dfault);
   }
}
