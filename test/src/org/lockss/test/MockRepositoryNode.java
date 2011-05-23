/*
 * $Id: MockRepositoryNode.java,v 1.15.56.4 2011-05-23 22:34:24 dshr Exp $
 */

/*

Copyright (c) 2000-2003 Board of Trustees of Leland Stanford Jr. University,
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

package org.lockss.test;

import java.io.*;
import java.util.*;
import org.apache.commons.vfs.*;

import org.lockss.daemon.CachedUrlSetSpec;
import org.lockss.protocol.PeerIdentity;
import org.lockss.repository.*;
import org.lockss.util.*;

/**
 * Mock version of the RepositoryNode.
 */
public class MockRepositoryNode implements RepositoryNode {
  public boolean newVersionOpen = false;
  public boolean newOutputCalled = false;
  public boolean newPropsSet = false;
  public boolean inactive = false;
  public boolean deleted = false;
  public Vector children = null;
  public long contentSize = 0;
  public InputStream curInput;
  public Properties curProps;
  public int currentVersion = -1;
  public HashSet agreeingPeers = new HashSet();

  public String url;
  public String nodeLocation;

  public FileObject nodeDir;
  protected static Logger logger = Logger.getLogger("MockRepositoryNode");

  public MockRepositoryNode() {
  }

  public MockRepositoryNode(String url, String nodeLocation) {
    this.url = url;
    this.nodeLocation = nodeLocation;
    try {
      // nodeLocation is a URL
      nodeDir = VFS.getManager().resolveFile(nodeLocation);
    } catch (FileSystemException e) {
      throw new UnsupportedOperationException(nodeLocation + " bad");
    }
  }

  public String getNodeUrl() {
    return url;
  }

  public boolean hasContent() {
    return currentVersion>0;
  }

  public boolean isContentInactive() {
    return inactive;
  }

  public boolean isDeleted() {
    return deleted;
  }

  public void markAsDeleted() {
    deleted = true;
  }

  public void markAsNotDeleted() {
    deleted = false;
  }

  public long getContentSize() {
    return contentSize;
  }

  public long getTreeContentSize(CachedUrlSetSpec filter,
				 boolean calcIfUnknown) {
    throw new UnsupportedOperationException("Not supported.");
  }

  public int getChildCount() {
    return children.size();
  }

  public Properties getState() {
    return null;
  }

  public void storeState(Properties newProps) {
  }

  public boolean isLeaf() {
    return (children==null || children.size()>0);
  }

  public Iterator listChildren(CachedUrlSetSpec filter, boolean includeInactive) {
    if (children == null) return CollectionUtil.EMPTY_ITERATOR;
    return children.iterator();
  }

  public int getVersion() {
    return getCurrentVersion();
  }

  public int getCurrentVersion() {
    return currentVersion;
  }

  public synchronized void makeNewVersion() {
    if (newVersionOpen) {
      throw new UnsupportedOperationException("New version already initialized.");
    }
    newVersionOpen = true;
  }

  public synchronized void sealNewVersion() {
    if (!newVersionOpen) {
      throw new UnsupportedOperationException("New version not initialized.");
    }
    currentVersion++;
    curProps = null;
    newOutputCalled = false;
    newPropsSet = false;
    newVersionOpen = false;
  }

  public synchronized void abandonNewVersion() {
    if (!newVersionOpen) {
      throw new UnsupportedOperationException("New version not initialized.");
    }
    newOutputCalled = false;
    newPropsSet = false;
    newVersionOpen = false;
  }

  public synchronized void deactivateContent() {
    if (newVersionOpen) {
      throw new UnsupportedOperationException("Can't deactivate while new version open.");
    }
    inactive = true;
    curProps = null;
  }

  public synchronized void restoreLastVersion() {
    throw new UnsupportedOperationException("Not supported.");
  }

  public RepositoryNodeVersion[] getNodeVersions() {
    throw new UnsupportedOperationException("Not supported.");
  }

  public RepositoryNodeVersion[] getNodeVersions(int maxVersions) {
    throw new UnsupportedOperationException("Not supported.");
  }

  public RepositoryNodeVersion getNodeVersion(int version) {
    throw new UnsupportedOperationException("Not supported.");
  }

  public InputStream getPeerIdInputStream(String fileName) {
    logger.debug3("getPeerIdInputStream " + fileName);
    InputStream ret = null;
    try {
      if (nodeDir != null) {
	FileObject fo = nodeDir.resolveFile(fileName);
	if (fo.isReadable()) {
	  return fo.getContent().getInputStream();
	} else {
	  return null;
	}
      }
      throw new
	UnsupportedOperationException("MockRepositoryNode needs nodeLocation" +
				      " to use " + fileName);
    } catch (FileSystemException ex) {
      throw new UnsupportedOperationException(nodeLocation + File.separator +
					      fileName + " threw " + ex);
    }
    
  }

  public OutputStream getPeerIdOutputStream(String fileName)
    throws IOException {
    logger.debug3("getPeerIdOutputStream " + fileName);
    OutputStream ret = null;
    try {
      if (nodeDir != null) {
	FileObject fo = nodeDir.resolveFile(fileName);
	if (fo.isWriteable()) {
	  return fo.getContent().getOutputStream();
	} else {
	  throw new IOException("not writable");
	}
      }
      throw new
	UnsupportedOperationException("MockRepositoryNode needs nodeLocation" +
				      " to use " + fileName);
    } catch (FileSystemException ex) {
      throw new UnsupportedOperationException(nodeLocation + File.separator +
					      fileName + " threw " + ex);
    }
  }

  public FileObject getPeerIdFileObject(String fileName) {
    logger.debug3("getPeerIdFileObject " + fileName);
    if (logger.isDebug3()) {
      (new Throwable()).printStackTrace();
    }
    FileObject ret = null;
    try {
      if (nodeDir != null) {
	return nodeDir.resolveFile(fileName);
      }
      throw new
	UnsupportedOperationException("MockRepositoryNode needs nodeLocation" +
				      " to use " + fileName);
    } catch (FileSystemException ex) {
      throw new UnsupportedOperationException(nodeLocation + File.separator +
					      fileName + " threw " + ex);
    }
  }

  public boolean updatePeerIdFile(String fileName) {
    logger.debug3("updatePeerIdFile " + fileName);
    if (logger.isDebug3()) {
      (new Throwable()).printStackTrace();
    }
    boolean ret = false;
    if (fileName.endsWith(".temp")) {
      FileObject fo = getPeerIdFileObject(fileName);
      FileObject fn =
	getPeerIdFileObject(fileName.substring(0,fileName.length()-5));
      try {
	if (fo.canRenameTo(fn)) {
	  fo.moveTo(fn);
	  ret = true;
	}
      } catch (FileSystemException ex) {
	throw new UnsupportedOperationException(fileName + " threw " + ex);
      }
      return ret;
    }
    throw new UnsupportedOperationException("Not supported." + fileName);
  }

  public synchronized RepositoryNode.RepositoryNodeContents getNodeContents() {
    if (!hasContent()) {
      throw new UnsupportedOperationException("No content for url '"+url+"'");
    }
    return new MockRepositoryNodeContents(curInput, curProps);
  }

  public void signalAgreement(Collection ids) {
    for (Iterator it = ids.iterator(); it.hasNext(); ) {
      agreeingPeers.add((PeerIdentity)it.next());
    }
  }
  
  public boolean hasAgreement(PeerIdentity id) {
    return agreeingPeers.contains(id);
  }
  
  public OutputStream getNewOutputStream() {
    throw new UnsupportedOperationException("Not supported.");
  }

  public void setNewProperties(Properties newProps) {
    throw new UnsupportedOperationException("Not supported.");
  }

  class MockRepositoryNodeContents implements RepositoryNodeContents {
    private InputStream is;
    private Properties props;

    private MockRepositoryNodeContents(InputStream is, Properties props) {
      this.is = is;
      this.props = props;
    }

    public InputStream getInputStream() {
      return is;
    }

    public Properties getProperties() {
      return props;
    }

    public void release() {
    }
  }
}
