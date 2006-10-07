/*
 * $Id: PollerStateBean.java,v 1.17 2006-10-07 02:01:27 smorabito Exp $
 */

/*
Copyright (c) 2000-2005 Board of Trustees of Leland Stanford Jr. University,
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

package org.lockss.poller.v3;

import java.util.*;

import org.lockss.hasher.HashBlock;
import org.lockss.plugin.*;
import org.lockss.poller.*;
import org.lockss.protocol.*;
import org.lockss.protocol.psm.*;
import org.lockss.util.*;

/**
 * Persistant state object for the V3Poller.
 */
public class PollerStateBean implements LockssSerializable {

  /* Unique poll identifier. */
  private String pollKey;
  /* The time by which the poll must have completed. */
  private long pollDeadline;
  /* The time by which all voters must have voted. */
  private long voteDeadline;
  /* The requested duration of this poll. */
  private long duration;
  /* The ArchivalUnit identifier. */
  private String auId;
  /* The version of the plugin used by the AU. */
  private String pluginVersion;
  /* The version of the polling protocol to use. */
  private int protocolVersion;
  private String url;
  private PeerIdentity pollerId;
  private String hashAlgorithm;
  private long createTime;
  private int pollSize;
  private int quorum;
  private int hashBlockIndex;
  private int outerCircleTarget;
  private String statusString;
  private int status;
  private RepairQueue repairQueue;
  private ArrayList hashedBlocks; // This will need to be disk-based in 1.16!
  private boolean hashStarted;
  private Collection votedPeers;
  private TallyStatus tallyStatus;
  private String errorDetail; // If non-null, detailed information to be
  // displayed in the status table regarding any kind of error state.

  /* Non-serializable transient fields */
  private transient PollSpec spec;
  private transient CachedUrlSet cus;

  private static Logger log = Logger.getLogger("PollerStateBean");

  /**
   * Counter of participants whose state machines do not want to allow the next
   * block to hash. When the poller checks to see if it can start hashing the
   * next block, it will consult this counter and only proceed if it is '0'.
   */
  //private volatile int hashReadyCounter;

  /**
   * Counter of participants who have not yet nominated any peers.
   */
  private volatile int nomineeCounter;

  /**
   * The target URL of the most recently hashed block. Updated after each block
   * is hashed and tallied by V3Poller. Used when returning to tally more blocks
   * after requesting a repair, or when sending a vote request for the next in a
   * sequence of votes.
   */
  private String lastHashedBlock;

  protected PollerStateBean() {}

  public PollerStateBean(PollSpec spec, PeerIdentity orig, String pollKey,
                         long duration, int pollSize, int outerCircleTarget,
                         int quorum, String hashAlg) {
    this.pollerId = orig;
    this.pollKey = pollKey;
    this.duration = duration;
    this.pollDeadline = Deadline.in(duration).getExpirationTime();
    this.pollSize = pollSize;
    //this.hashReadyCounter = pollSize;
    this.nomineeCounter = pollSize;
    this.outerCircleTarget = outerCircleTarget;
    this.auId = spec.getAuId();
    this.protocolVersion = spec.getProtocolVersion();
    this.pluginVersion = spec.getPluginVersion();
    this.url = spec.getUrl();
    this.cus = spec.getCachedUrlSet();
    this.spec = spec;
    this.hashAlgorithm = hashAlg;
    this.createTime = TimeBase.nowMs();
    this.quorum = quorum;
    this.hashBlockIndex = 0;
    this.statusString = "Initializing";
    this.repairQueue = new RepairQueue();
    this.hashedBlocks = new ArrayList();
    this.votedPeers = new ArrayList();
    this.tallyStatus = new TallyStatus();
  }

  public long getCreateTime() {
    return createTime;
  }

  public void setPollKey(String id) {
    this.pollKey = id;
  }

  public String getPollKey() {
    return pollKey;
  }

  public int getPollSize() {
    return pollSize;
  }

  public void setPollSize(int pollSize) {
    this.pollSize = pollSize;
  }

  public void setPollerId(PeerIdentity pollerId) {
    this.pollerId = pollerId;
  }

  public PeerIdentity getPollerId() {
    return pollerId;
  }

  public void setLastHashedBlock(String target) {
    this.lastHashedBlock = target;
  }

  public String getLastHashedBlock() {
    return lastHashedBlock;
  }

  public void setAuId(String auId) {
    this.auId = auId;
  }

  public String getAuId() {
    return auId;
  }

  public void setProtocolVersion(int protocolVersion) {
    this.protocolVersion = protocolVersion;
  }

  public int getProtocolVersion() {
    return protocolVersion;
  }

  public void setPluginVersion(String pluginVersion) {
    this.pluginVersion = pluginVersion;
  }

  public String getPluginVersion() {
    return pluginVersion;
  }

  public void setUrl(String url) {
    this.url = url;
  }

  public String getUrl() {
    return url;
  }

  public void setCachedUrlSet(CachedUrlSet cus) {
    this.cus = cus;
  }

  public CachedUrlSet getCachedUrlSet() {
    return cus;
  }

  public void setPollSpec(PollSpec spec) {
    this.spec = spec;
  }

  public PollSpec getPollSpec() {
    return spec;
  }

  public void setHashAlgorithm(String hashAlgorithm) {
    this.hashAlgorithm = hashAlgorithm;
  }

  public String getHashAlgorithm() {
    return hashAlgorithm;
  }

  public void setPollDeadline(long l) {
    this.pollDeadline = l;
  }

  public long getPollDeadline() {
    return pollDeadline;
  }

  public void setVoteDeadline(long l) {
    this.voteDeadline = l;
  }

  public long getVoteDeadline() {
    return this.voteDeadline;
  }

  public long getDuration() {
    return duration;
  }

  public void setDuration(long duration) {
    this.duration = duration;
  }

  public int getQuorum() {
    return quorum;
  }

  public void setQuorum(int quorum) {
    this.quorum = quorum;
  }

  public boolean hashStarted() {
    return hashStarted;
  }

  public void hashStarted(boolean b) {
    this.hashStarted = b;
  }

  // Simple counter
  public void addVotedPeer(PeerIdentity id) {
    votedPeers.add(id);
  }

  public Collection getVotedPeers() {
    return votedPeers;
  }

  public int getOuterCircleTarget() {
    return outerCircleTarget;
  }

  public void setOuterCircleTarget(int outerCircleTargetSize) {
    this.outerCircleTarget = outerCircleTargetSize;
  }

  public void signalVoterNominated(PeerIdentity id) {
    nomineeCounter--;
  }

  /**
   * Return true if the V3Poller should proceed to request votes.
   *
   * @return true if the poller should proceed to requesting votes.
   */
  public boolean sufficientPeers() {
    return nomineeCounter >= getQuorum();
  }

  /**
   * Return the ordered list of hashed blocks.
   */
  public ArrayList getHashedBlocks() {
    return hashedBlocks;
  }

  public void addHashBlock(HashBlock hb) {
    hashedBlocks.add(hb);
  }
  
  public String toString() {
    StringBuffer sb = new StringBuffer("[V3PollerState: ");
    sb.append("pollKey=" + pollKey + ", ");
    sb.append("deadline=" + pollDeadline + "]");
    return sb.toString();
  }
  
  /**
   * @deprecated Use getStatus instead.
   * @return The status of this poll, as a string.
   */
  public String getStatusString() {
    return statusString;
  }

  /**
   * Set the status of this poll
   * @deprecated Use setStatus instead.
   */
  public void setStatusString(String s) {
    this.statusString = s;
  }

  /**
   * Return the status of this poll.
   */
  public int getStatus() {
    return status;
  }
  
  public boolean expectingRepairs() {
    return (repairQueue.getPendingRepairs().size() + 
        repairQueue.getActiveRepairs().size()) > 0;
  }

  /**
   * Set the status of this poll.
   *
   * @param s Current status
   */
  public void setStatus(int s) {
    this.status = s;
  }

  public RepairQueue getRepairQueue() {
    return repairQueue;
  }

  public TallyStatus getTallyStatus() {
    return tallyStatus;
  }

  public void setErrorDetail(String err) {
    this.errorDetail = err;
  }
  
  public String getErrorDetail() {
    return errorDetail;
  }

  /**
   * Simple object to hold tally status.
   */
  public static class TallyStatus implements LockssSerializable {
    public Set agreedUrls;
    public Set disagreedUrls;
    public Set tooCloseUrls;
    public Set noQuorumUrls;

    public TallyStatus() {
      agreedUrls = new HashSet();
      disagreedUrls = new HashSet();
      tooCloseUrls = new HashSet();
      noQuorumUrls = new HashSet();
    }

    public void addAgreedUrl(String url) {
      removeUrl(url);
      agreedUrls.add(url);
    }

    public void addDisagreedUrl(String url) {
      removeUrl(url);
      disagreedUrls.add(url);
    }

    public void addTooCloseUrl(String url) {
      removeUrl(url);
      tooCloseUrls.add(url);
    }

    public void addNoQuorumUrl(String url) {
      removeUrl(url);
      noQuorumUrls.add(url);
    }

    private void removeUrl(String url) {
      agreedUrls.remove(url);
      disagreedUrls.remove(url);
      tooCloseUrls.remove(url);
      noQuorumUrls.remove(url);
    }
  }

  /**
   * Simple object to hold status for a repair.
   */
  public static class Repair implements LockssSerializable {
    /** The URL of the block being repaired. */
    protected String url;
    /** Peer from which to request a repair. If null, this is a 
     * publisher repair. */
    protected PeerIdentity repairFrom;
    /** Ordered map of peers to votes cast for this block. */
    protected LinkedHashMap previousVotes;
    
    /**
     * The following deprecated members were emoved in daemon 1.20.
     */
    
    /** @deprecated */ 
    protected boolean repairFromPublisher = false;
    /** @deprecated */
    protected boolean deletedFile = false;

    /**
     * Create a publisher repair object.
     * 
     * @param url
     * @param previousVotes
     */
    public Repair(String url, LinkedHashMap previousVotes) {
      this(url, previousVotes, null);
    }
    
    /**
     * Create a peer repair object.
     * 
     * @param url
     * @param previousVotes
     * @param repairFrom
     */
    public Repair(String url, LinkedHashMap previousVotes, PeerIdentity repairFrom) {
      this.url = url;
      this.previousVotes = previousVotes;
      this.repairFrom = repairFrom;
    }

    public LinkedHashMap getPreviousVotes() {
      return previousVotes;
    }

    public void setPreviousVotes(LinkedHashMap previousVotes) {
      this.previousVotes = previousVotes;
    }

    public PeerIdentity getRepairFrom() {
      return repairFrom;
    }

    public void setRepairFrom(PeerIdentity repairFrom) {
      this.repairFrom = repairFrom;
    }

    public void setRepairFromPublisher() {
      setRepairFrom(null);
    }

    public String getUrl() {
      return url;
    }

    public void setUrl(String url) {
      this.url = url;
    }

    public boolean isPublisherRepair() {
      return (repairFrom == null);
    }

    /** @deprecated */
    public void setDeletedFile() {}
  }

  /**
   * Collection of repairs, active and completed.
   */
  
  public static class RepairQueue implements LockssSerializable {
    private Map pendingRepairs;
    private Map activeRepairs;
    private List completedRepairs;
    
    public RepairQueue() {
      this.pendingRepairs = new HashMap();
      this.activeRepairs = new HashMap();
      this.completedRepairs = new ArrayList();
    }

    public synchronized void repairFromPublisher(String url, LinkedHashMap previousVotes) {
      pendingRepairs.put(url, new Repair(url, previousVotes));
    }
    
    public synchronized void repairFromPeer(String url, LinkedHashMap previousVotes, 
                                            PeerIdentity peer) {
      pendingRepairs.put(url, new Repair(url, previousVotes, peer));
    }
    
    /**
     * Return a list of all pending repairs that should be fetched from
     * the publisher.
     * 
     * @return
     */
    public synchronized List getPendingPublisherRepairs() {
      List publisherRepairs = new ArrayList();
      for (Iterator iter = pendingRepairs.keySet().iterator(); iter.hasNext(); ) {
        String url = (String)iter.next();
        Repair r = (Repair)pendingRepairs.get(url);
        if (r.isPublisherRepair()) {
          publisherRepairs.add(r);
        }
      }
      return publisherRepairs;
    }
    
    /**
     * Convenience method to return just the URLs of the pending publisher
     * suitable to passing to the repair crawler.
     */
    public synchronized List getPendingPublisherRepairUrls() {
      List publisherRepairs = new ArrayList();
      for (Iterator iter = pendingRepairs.keySet().iterator(); iter.hasNext(); ) {
        String url = (String)iter.next();
        Repair r = (Repair)pendingRepairs.get(url);
        if (r.isPublisherRepair()) {
          publisherRepairs.add(url);
        }
      }
      return publisherRepairs;
    }
    
    /**
     * Return a list of all pending repairs that should be fetched from
     * other V3 peers.
     * 
     * @return
     */
    public synchronized List getPendingPeerRepairs() {
      List peerRepairs = new ArrayList();
      for (Iterator iter = pendingRepairs.keySet().iterator(); iter.hasNext(); ) {
        String url = (String)iter.next();
        Repair r = (Repair)pendingRepairs.get(url);
        if (!r.isPublisherRepair()) {
          peerRepairs.add(r);
        }
      }
      return peerRepairs;
    }

    public synchronized Map getVotesForBlock(String url) {
      Repair rep = (Repair)activeRepairs.get(url);
      if (rep != null) {
        return rep.getPreviousVotes();
      } else {
        return null;
      }
    }
    
    public synchronized List getPendingRepairs() {
      return new ArrayList(pendingRepairs.values());
    }

    public synchronized List getActiveRepairs() {
      return new ArrayList(activeRepairs.values());
    }
    
    public synchronized List getCompletedRepairs() {
      return completedRepairs;
    }
    
    /**
     * Mark an entire list of URls active.
     * 
     * @param l The list of URLs to move to the active state.
     */
    public synchronized void markActive(List l) {
      for (Iterator iter = l.iterator(); iter.hasNext(); ) {
        markActive((String)iter.next());
      }
    }

    public synchronized void markActive(String url) {
      Repair r = (Repair)pendingRepairs.remove(url);
      if (r != null) {
        activeRepairs.put(url, r);
      }
    }
    
    /** Deletions go directly from 'pending' to 'completed' */
    public synchronized void markComplete(String url) {
      Repair r = (Repair)activeRepairs.remove(url);
      if (r == null) {
        r = (Repair)pendingRepairs.remove(url);
      }
      if (r != null) {
        completedRepairs.add(r);
      }
    }
  }

}
