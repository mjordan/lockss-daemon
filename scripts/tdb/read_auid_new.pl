#!/usr/bin/perl -w

use URI::Escape;
use Getopt::Long;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Cookies;
use HTML::Entities;
use utf8;
#use encoding 'utf8';
use Encode qw(decode encode);

my $lockss_tag  = "LOCKSS system has permission to collect, preserve, and serve this Archival Unit";
my $oa_tag      = "LOCKSS system has permission to collect, preserve, and serve this open access Archival Unit";
my $clockss_tag = "CLOCKSS system has permission to ingest, preserve, and serve this Archival Unit";
my $cc_license_tag = "rel..license";
my $cc_license_url = "href=\"https?://creativecommons\.org/licenses/(by|by-sa|by-nc|by-nd|by-nc-sa|by-nc-nd)/(1\.0|2\.0|2\.5|3\.0|4\.0)/?.";
my $cc_by_tag = "href=\"https?://creativecommons.org/licenses/by";
my $bmc_tag = "<span>Archive</span>";
my $bmc2_tag = "<span>Issues</span>";
my $igi_tag = "/gateway/issue/";
my $total_manifests = 0;
my $total_missing = 0;
my $total_missing_plugin = 0;
my $datestring = localtime();

# Set up "cookie jar" to hold session cookies for Web access.
# Don't save these cookies from run to run.
my $cjar = HTTP::Cookies->new();

# Create user agent.
my $ua = LWP::UserAgent->new( cookie_jar => $cjar, agent => "LOCKSS cache" );
$ua->proxy('http', 'http://proxy.lockss.org:8888/');
$ua->no_proxy('localhost', '127.0.0.1');

while (my $line = <>) {
  chomp $line;
  my $auid_long = $line;
  my @input_rec = split(/\|/, $line);
  my $num_elements = int(@input_rec);
  my $auid = $input_rec[$num_elements-1];
  my @auid_rec = split(/\&/, $auid);
  my $plugin = shift(@auid_rec);
  my %param = ();
  foreach my $param_entry (@auid_rec) {
    if ($param_entry =~ m/^([^\~]+)\~([^\~]+)$/) {
      $param{$1} = $2;
    }
  }
  my $url = "cant_create_url";
  my $url_p = "cant_create_url";
  my $url_s = "cant_create_url";
  my $url_d = "cant_create_url";
  my $url_e = "cant_create_url";
  my $url_de = "cant_create_url";
  #my $url_permission = "cant_create_url";
  my $man_url = "cant_create_url";
  my $man_url_p = "cant_create_url";
  my $man_url_s = "cant_create_url";
  my $man_url_d = "cant_create_url";
  my $man_url_e = "cant_create_url";
  my $man_url_de = "cant_create_url";
  my $vol_title = "NO TITLE FOUND";
  my $result = "Plugin Unknown";


  #if ($plugin eq "HighWirePressH20Plugin" || $plugin eq "HighWirePressPlugin") {
  if ($plugin eq "HighWirePressH20Plugin") {
    $url = sprintf("%slockss-manifest/vol_%s_manifest.dtl",
      $param{base_url}, $param{volume_name});
    $url_d = sprintf("%slockss-manifest/vol_%s_manifest.html",
      $param{base_url}, $param{volume_name});
    $man_url = uri_unescape($url);
    $man_url_d = uri_unescape($url_d);
    $base_url_short = substr(uri_unescape($param{base_url}), 0, -1);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      #printf("Req:%s\nResp:%s\nurl_d:%s\n",$req->url,$resp->request->uri,$man_url_d);
      if ($req->url ne $resp->request->uri) {
        $vol_title = $resp->request->uri;
        if ($resp->request->uri eq $man_url_d) {
          #printf("Uses Drupal plugin\n");
          $result = "Moved_to_Drupal";
        } else {
          #printf("Doesn't use Drupal plugin\n");
          $result = "Redirected";
        }
        #$result = "Redirected";
      } elsif (defined($man_contents) && (($man_contents =~ m/\/cgi\/reprint\/$param{volume_name}\//) || ($man_contents =~ m/$base_url_short" lockss-probe/))) {
          $result = "CGI_probe_link";
          if ($man_contents =~ m/<title>\s*(.*)\s+C?LOCKSS\s+Manifest\s+Page.*<\/title>/si) {
            $vol_title = $1;
            $vol_title =~ s/\s*\n\s*/ /g;
            if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
              $vol_title = "\"" . $vol_title . "\"";
            }
          }
      } elsif (defined($man_contents) && (($man_contents =~ m/$lockss_tag/) || ($man_contents =~ m/$oa_tag/)) && (($man_contents =~ m/\/content\/$param{volume_name}\//) || ($man_contents =~ m/\/content\/vol$param{volume_name}\//))) {
        $result = "Manifest";
        if ($man_contents =~ m/<title>\s*(.*)\s+C?LOCKSS\s+Manifest\s+Page.*<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

  #} elsif ($plugin eq "ClockssHighWirePressH20Plugin" || $plugin eq "ClockssHighWirePlugin") {
  } elsif ($plugin eq "ClockssHighWirePressH20Plugin") {
        $url = sprintf("%sclockss-manifest/vol_%s_manifest.dtl",
            $param{base_url}, $param{volume_name});
        $url_d = sprintf("%sclockss-manifest/vol_%s_manifest.html",
            $param{base_url}, $param{volume_name});
        $man_url = uri_unescape($url);
        $man_url_d = uri_unescape($url_d);
        $base_url_short = substr(uri_unescape($param{base_url}), 0, -1);
        my $req = HTTP::Request->new(GET, $man_url);
        my $resp = $ua->request($req);
        if ($resp->is_success) {
            my $man_contents = $resp->content;
            if ($req->url ne $resp->request->uri) {
              $vol_title = $resp->request->uri;
              if ($resp->request->uri eq $man_url_d) {
                #printf("Uses Drupal plugin\n");
                $result = "Moved_to_Drupal";
              } else {
                #printf("Doesn't use Drupal plugin\n");
                $result = "Redirected";
              }
              #$result = "Redirected";
            } elsif (defined($man_contents) && (($man_contents =~ m/\/cgi\/reprint\/$param{volume_name}\//) || ($man_contents =~ m/$base_url_short" lockss-probe/))) {
                $result = "CGI_probe_link";
                if ($man_contents =~ m/<title>\s*(.*)\s+C?LOCKSS\s+Manifest\s+Page.*<\/title>/si) {
                    $vol_title = $1;
                    $vol_title =~ s/\s*\n\s*/ /g;
                    if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                        $vol_title = "\"" . $vol_title . "\"";
                    }
                }
            }  elsif (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && (($man_contents =~ m/\/content\/$param{volume_name}\//) || ($man_contents =~ m/\/content\/vol$param{volume_name}\//))) {
                $result = "Manifest";
                if ($man_contents =~ m/<title>\s*(.*)\s+C?LOCKSS\s+Manifest\s+Page.*<\/title>/si) {
                    $vol_title = $1;
                    $vol_title =~ s/\s*\n\s*/ /g;
                    if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                        $vol_title = "\"" . $vol_title . "\"";
                    }
                }
            } else {
                $result = "--"
            }
        } else {
            $result = "--"
        }
        sleep(4);

  } elsif ($plugin eq "AAPDrupalPlugin" ||
           $plugin eq "ADADrupalPlugin" ||
           $plugin eq "AHADrupalPlugin" ||
           $plugin eq "APSDrupalPlugin" ||
           $plugin eq "ARFDrupalPlugin" ||
           $plugin eq "ASHDrupalPlugin" ||
           $plugin eq "BESBJSDrupalPlugin" ||
           $plugin eq "BiologistsDrupalPlugin" ||
           $plugin eq "BMJDrupalPlugin" ||
           $plugin eq "EMBODrupalPlugin" ||
           $plugin eq "ERSDrupalPlugin" ||
           $plugin eq "FSFDrupalPlugin" ||
           $plugin eq "GeneticsSocietyDrupalPlugin" ||
           $plugin eq "GSLDrupalPlugin" ||
           $plugin eq "GSWDrupalPlugin" ||
           $plugin eq "IWADrupalPlugin" ||
           $plugin eq "JBJSDrupalPlugin" ||
           $plugin eq "OUPDrupalPlugin" ||
           $plugin eq "PortlandPressDrupalPlugin" ||
           $plugin eq "RCGPDrupalPlugin" ||
           $plugin eq "RCPsychDrupalPlugin" ||
           $plugin eq "RSPDrupalPlugin" ||
           $plugin eq "RUPDrupalPlugin" ||
           $plugin eq "SFNDrupalPlugin" ||
           $plugin eq "HWDrupalPlugin") {
        $url = sprintf("%slockss-manifest/vol_%s_manifest.html",
            $param{base_url}, $param{volume_name});
        $man_url = uri_unescape($url);
        $base_url_short = substr(uri_unescape($param{base_url}), 0, -1);
        my $req = HTTP::Request->new(GET, $man_url);
        my $resp = $ua->request($req);
        if ($resp->is_success) {
            my $man_contents = $resp->content;
            if ($req->url ne $resp->request->uri) {
              $result = "Redirected";
            } elsif (defined($man_contents) && (($man_contents =~ m/\/cgi\/reprint\/$param{volume_name}\//) || ($man_contents =~ m/$base_url_short" lockss-probe/))) {
                $result = "CGI_probe_link";
                if ($man_contents =~ m/<title>\s*(.*)\s+C?LOCKSS\s+Manifest\s+Page.*<\/title>/si) {
                    $vol_title = $1;
                    $vol_title =~ s/\s*\n\s*/ /g;
                    if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                        $vol_title = "\"" . $vol_title . "\"";
                    }
                }
            } elsif (defined($man_contents) && ($man_contents =~ m/$lockss_tag/) && (($man_contents =~ m/\/content\/$param{volume_name}\//) || ($man_contents =~ m/\/content\/vol$param{volume_name}\//))) {
                if ($man_contents =~ m/<title>\s*(.*)\s+C?LOCKSS\s+Manifest\s+Page.*<\/title>/si) {
                    $vol_title = $1;
                    $vol_title =~ s/\s*\n\s*/ /g;
                    if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                        $vol_title = "\"" . $vol_title . "\"";
                    }
                }
                $result = "Manifest"
            } else {
                $result = "--"
            }
        } else {
            $result = "--"
        }
        sleep(4);

  } elsif ($plugin eq "ClockssAAASDrupalPlugin" ||
           $plugin eq "ClockssAAPDrupalPlugin" ||
           $plugin eq "ClockssADADrupalPlugin" ||
           $plugin eq "ClockssAPSDrupalPlugin" ||
           $plugin eq "ClockssASPETDrupalPlugin" ||
           $plugin eq "ClockssBiologistsDrupalPlugin" ||
           $plugin eq "ClockssERSDrupalPlugin" ||
           $plugin eq "ClockssGSLDrupalPlugin" ||
           $plugin eq "ClockssGSWDrupalPlugin" ||
           $plugin eq "ClockssIWADrupalPlugin" ||
           $plugin eq "ClockssOUPDrupalPlugin" ||
           $plugin eq "ClockssPortlandPressDrupalPlugin" ||
           $plugin eq "ClockssRSPDrupalPlugin" ||
           $plugin eq "ClockssRUPDrupalPlugin" ||
           $plugin eq "ClockssHWDrupalPlugin") {
        $url = sprintf("%sclockss-manifest/vol_%s_manifest.html",
            $param{base_url}, $param{volume_name});
        $man_url = uri_unescape($url);
        $base_url_short = substr(uri_unescape($param{base_url}), 0, -1);
        my $req = HTTP::Request->new(GET, $man_url);
        my $resp = $ua->request($req);
        #printf("%s\" lockss-probe\n",$base_url_short);
        if ($resp->is_success) {
            my $man_contents = $resp->content;
            if ($req->url ne $resp->request->uri) {
              $result = "Redirected";
            } elsif (defined($man_contents) && (($man_contents =~ m/\/cgi\/reprint\/$param{volume_name}\//) || ($man_contents =~ m/$base_url_short" lockss-probe/))) {
                $result = "CGI_probe_link";
                if ($man_contents =~ m/<title>\s*(.*)\s+C?LOCKSS\s+Manifest\s+Page.*<\/title>/si) {
                    $vol_title = $1;
                    $vol_title =~ s/\s*\n\s*/ /g;
                    if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                        $vol_title = "\"" . $vol_title . "\"";
                    }
                }
            } elsif (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && (($man_contents =~ m/\/content\/$param{volume_name}\//) || ($man_contents =~ m/\/content\/vol$param{volume_name}\//))) {
                if ($man_contents =~ m/<title>\s*(.*)\s+C?LOCKSS\s+Manifest\s+Page.*<\/title>/si) {
                    $vol_title = $1;
                    $vol_title =~ s/\s*\n\s*/ /g;
                    if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                        $vol_title = "\"" . $vol_title . "\"";
                    }
                }
                $result = "Manifest"
            } else {
                $result = "--"
            }
        } else {
            $result = "--"
        }
        sleep(4);

#  } elsif ($plugin eq "ProjectMusePlugin") {
#        $url = sprintf("%sjournals/%s/v%03d/",
#            $param{base_url}, $param{journal_dir}, $param{volume});
#        $man_url = uri_unescape($url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && (($man_contents =~ m/$lockss_tag/) || ($man_contents =~ m/$oa_tag/)) && ($man_contents !~ "No issues avail")) {
#        if ($man_contents =~ m/<h1>(.*)<\/h1>/si) {
#          $vol_title = $1;
#          if ($man_contents =~ m/<h2>(.*)<\/h2>/si) {
#            $vol_title = $vol_title . " " . $1;
#          }
#          $vol_title =~ s/\s*\n\s*/ /g;
#          $vol_title =~ s/,//;
#        }
#    $result = "Manifest"
#      } else {
#    $result = "--"
#      }
#  } else {
#      $result = "--"
#  }
#        sleep(4);

  } elsif ($plugin eq "GPOFDSysSitemapsPlugin") {
      $url = sprintf("%ssmap/fdsys/sitemap_%d/%d_%s_sitemap.xml",
      $param{base_url}, $param{year}, $param{year}, $param{collection_id});
      $man_url = uri_unescape($url);
      my $req = HTTP::Request->new(GET, $man_url);
      my $resp = $ua->request($req);
      if ($resp->is_success) {
          my $man_contents = $resp->content;
          if (defined($man_contents) && (($man_contents =~ m/$lockss_tag/) || ($man_contents =~ m/$oa_tag/))) {
              $vol_title = $param{collection_id};
              $result = "Manifest"
          } else {
              $result = "--"
          }
      } else {
          $result = "--"
      }
      sleep(5);

  } elsif ($plugin eq "UbiquityPartnerNetworkPlugin") {
      $url = sprintf("%slockss/year/%d/",
          $param{base_url}, $param{year});
      $man_url = uri_unescape($url);
      my $req = HTTP::Request->new(GET, $man_url);
      my $resp = $ua->request($req);
      if ($resp->is_success) {
          my $man_contents = $resp->content;
          if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
              if ($man_contents =~ m/<title>\s*(.*)\s*<\/title>/si) {
                  $vol_title = $1;
              }
              if ($man_contents =~ m/\/articles\//) {
                  $result = "Manifest";
              } else {
                  $result = "--NO_CONT--";
              }
          } else {
              $result = "--NO_TAG--";
          }
      } else {
          $result = "--"
      }
      sleep(5);

  } elsif ($plugin eq "ClockssUbiquityPartnerNetworkPlugin") {
      $url = sprintf("%slockss/year/%d/",
          $param{base_url}, $param{year});
      $man_url = uri_unescape($url);
      my $req = HTTP::Request->new(GET, $man_url);
      my $resp = $ua->request($req);
      $url_p = sprintf("%sabout",
          $param{base_url});
      $man_url_p = uri_unescape($url_p);
      my $req_p = HTTP::Request->new(GET, $man_url_p);
      my $resp_p = $ua->request($req_p);
      if ($resp->is_success) {
          my $man_contents_p = $resp_p->content;
          if (defined($man_contents_p) && ($man_contents_p =~ m/$clockss_tag/)) {
              if ($man_contents_p =~ m/<title>\s*(.*)\s*<\/title>/si) {
                  $vol_title = $1;
              }
              my $man_contents = $resp->content;
              if (defined($man_contents) && ($man_contents =~ m/\/articles\//)) {
                  $result = "Manifest";
              } else {
                  $result = "--NO_CONT--";
              }
          } else {
              $result = "--NO_TAG--";
          }
      } else {
          $result = "--"
      }
      sleep(5);

  } elsif ($plugin eq "BePressPlugin") {
        $url = sprintf("%s%s/lockss-volume%d.html",
            $param{base_url}, $param{journal_abbr}, $param{volume});
        $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && (($man_contents =~ m/$lockss_tag/) || ($man_contents =~ m/$oa_tag/))) {
    if ($man_contents =~ m/<title>(.*) --.*<\/title>/si) {
        $vol_title = $1;
        $vol_title =~ s/\s*\n\s*/ /g;
        if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
      $vol_title = "\"" . $vol_title . "\"";
        }
    }
    $result = "Manifest"
      } else {
    $result = "--"
      }
  } else {
      $result = "--"
  }
        sleep(4);

  } elsif ($plugin eq "ClockssBerkeleyElectronicPressPlugin") {
        $url = sprintf("%s%s/lockss-volume%d.html",
            $param{base_url}, $param{journal_abbr}, $param{volume});
        $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && (($man_contents =~ m/$clockss_tag/))) {
    if ($man_contents =~ m/<title>(.*) --.*<\/title>/si) {
        $vol_title = $1;
        $vol_title =~ s/\s*\n\s*/ /g;
        if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
      $vol_title = "\"" . $vol_title . "\"";
        }
    }
    $result = "Manifest"
      } else {
    $result = "--"
      }
  } else {
      $result = "--"
  }
        sleep(4);

  } elsif ($plugin eq "OJS2Plugin" || $plugin eq "CoActionPublishingPlugin") {
        $url = sprintf("%sindex.php/%s/gateway/lockss?year=%d",
            $param{base_url}, $param{journal_id}, $param{year});
        $man_url = uri_unescape($url);
        # default url if no manifest pages set up.
        $url_d = sprintf("%sindex.php/%s/index",
            $param{base_url}, $param{journal_id});
        $man_url_d = uri_unescape($url_d);
        # default url w/o index.php if no manifest pages set up.
        $url_de = sprintf("%s%s/index",
            $param{base_url}, $param{journal_id});
        $man_url_de = uri_unescape($url_de);
        # no index.php.
        $url_e = sprintf("%s%s/gateway/lockss?year=%d",
            $param{base_url}, $param{journal_id}, $param{year});
        $man_url_e = uri_unescape($url_e);
        #printf("man_url_e: %s\n", $man_url_e);

        my $req = HTTP::Request->new(GET, $man_url);
        my $resp = $ua->request($req);
        if ($resp->is_success) {
            my $man_contents = $resp->content;
            #printf("resp-request-uri: %s\n", $resp->request->uri);
            if ($req->url ne $resp->request->uri && ($resp->request->uri ne $man_url_d && $resp->request->uri ne $man_url_e && $resp->request->uri ne $man_url_de)) {
                $vol_title = $resp->request->uri;
                $result = "Redirected";
            } elsif (defined($man_contents) && (($man_contents =~ m/$lockss_tag/) || ($man_contents =~ m/$oa_tag/)) && (($man_contents =~ m/\($param{year}\)/) || ($man_contents =~ m/: $param{year}/))) {
                if ($man_contents =~ m/<title>([^<>]*)<\/title>/si) {
                    $vol_title = $1;
                    $vol_title =~ s/\s*\n\s*/ /g;
                    if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                        $vol_title = "\"" . $vol_title . "\"";
                    }
                }
                $result = "Manifest"
            } else {
                #$result = "--NO_TAG--";
                if (!defined($man_contents)) {
                    $result = "--NO_CONT--";
                } elsif (($man_contents !~ m/$lockss_tag/) && ($man_contents !~ m/$oa_tag/)) {
                    $result = "--NO_TAG--";
                } elsif (($man_contents !~ m/\($param{year}\)/) && ($man_contents !~ m/: $param{year}/)) {
                    $result = "--NO_YEAR--";
                } else {
                    $result = "--MYST--";
                }
            }
        } else {
            $result = "--REQ_FAIL--"
        }
        sleep(4);

  } elsif ($plugin eq "ClockssOJS2Plugin") {
        #Url with permission statement
        $url_m = sprintf("%sindex.php/%s/about/editorialPolicies",
            $param{base_url}, $param{journal_id});
        $man_url = uri_unescape($url_m);
        my $req_m = HTTP::Request->new(GET, $man_url);
        my $resp_m = $ua->request($req_m);
        #Url with permission statement - Alternate. No index.php
        $url_m_alt = sprintf("%s%s/about/editorialPolicies",
            $param{base_url}, $param{journal_id});
        $man_url_alt = uri_unescape($url_m_alt);
        my $req_m_alt = HTTP::Request->new(GET, $man_url_alt);
        #my $resp_m_alt = $ua->request($req_m_alt);
        #Url with list of urls for issues
        $url_s = sprintf("%sindex.php/%s/gateway/lockss?year=%d",
            $param{base_url}, $param{journal_id}, $param{year});
        $start_url = uri_unescape($url_s);
        my $req_s = HTTP::Request->new(GET, $start_url);
        my $resp_s = $ua->request($req_s);
        #For reporting at the end
        $man_url = $start_url . " + " . $man_url ;
        if (($resp_s->is_success) && ($resp_m->is_success)) {
            my $man_contents = $resp_m->content;
            my $start_contents = $resp_s->content;
            if ((($req_m->url ne $resp_m->request->uri) && ($req_m_alt->url ne $resp_m->request->uri)) || ($req_s->url ne $resp_s->request->uri)) {
                $vol_title = $req_m->url . " NOT " . $resp_m->request->uri . " OR " . $req_s->url . " NOT " . $resp_s->request->uri;
                $result = "Redirected";
            } elsif (defined($man_contents) && defined($start_contents) && (($man_contents =~ m/$clockss_tag/) || ($man_contents =~ m/$oa_tag/)) && (($start_contents =~ m/\($param{year}\)/) || ($start_contents =~ m/: $param{year}/))) {
                $result = "Manifest"
            } else {
                #$result = "--NO_TAG--"
                if (!defined($man_contents) || !defined($start_contents)) {
                    $result = "--NO_CONT--";
                } elsif (($man_contents !~ m/$lockss_tag/) && ($man_contents !~ m/$oa_tag/)) {
                    $result = "--NO_TAG--";
                } elsif (($man_contents !~ m/\($param{year}\)/) && ($man_contents !~ m/: $param{year}/)) {
                    $result = "--NO_YEAR--";
                } else {
                    $result = "--MYST--";
                }
            }
        } else {
            $result = "--REQ_FAIL--";
        }
        sleep(4);

  } elsif ($plugin eq "ClockssCoActionPublishingPlugin") {
        #Url with list of urls for issues
        $url = sprintf("%sindex.php/%s/gateway/lockss?year=%d",
            $param{base_url}, $param{journal_id}, $param{year});
        $start_url = uri_unescape($url);
        my $req_s = HTTP::Request->new(GET, $start_url);
        my $resp_s = $ua->request($req_s);
        #For reporting at the end
        $man_url = $start_url ;
    if ($resp_s->is_success) {
      my $start_contents = $resp_s->content;
      if (defined($start_contents) && (($start_contents =~ m/$cc_license_tag/) && ($start_contents =~ m/$cc_license_url/)) && (($start_contents =~ m/\($param{year}\)/) || ($start_contents =~ m/: $param{year}/))) {
         if ($start_contents =~ m/meta name=.description. content=.(.*) is an international/si) {
            $vol_title = $1;
        }
         $result = "Manifest"
      } else {
         $result = "--"
      }
    } else {
      $result = "--"
    }
        sleep(4);

  } elsif ($plugin eq "PensoftPlugin" || $plugin eq "ClockssPensoftPlugin") {
        #Url with list of urls for issues
        $url = sprintf("%sjournals/%s/archive?year=%d",
            $param{base_url}, $param{journal_name}, $param{year});
        $start_url = uri_unescape($url);
        my $req_s = HTTP::Request->new(GET, $start_url);
        my $resp_s = $ua->request($req_s);
        #For reporting at the end
        $man_url = $start_url ;
    if ($resp_s->is_success) {
      my $start_contents = $resp_s->content;
      if (defined($start_contents) && (($start_contents =~ m/$cc_license_tag/) && ($start_contents =~ m/$cc_license_url/)) && ($start_contents =~ m/\($param{year}\)/)) {
         if ($start_contents =~ m/<title>(.*) - Pensoft<\/title>/si) {
            $vol_title = $1 . "Volume " . $param{year};
        }
         $result = "Manifest"
      } else {
         $result = "--"
      }
    } else {
      $result = "--"
    }
        sleep(4);

  } elsif ($plugin eq "GeorgThiemeVerlagPlugin") {
        #Url with list of urls for issues
        #printf("%s\n",decode_entities($tmp));
        $url = sprintf("%sejournals/issues/%s/%s",
          $param{base_url}, $param{journal_id}, $param{volume_name});
        $man_url = uri_unescape($url);
        my $doi = uri_unescape($param{journal_id});
        my $req = HTTP::Request->new(GET, $man_url);
        my $resp = $ua->request($req);
        if ($resp->is_success) {
            my $man_contents = $resp->content;
            #no lockss permission statement on start page. Permission statement is here: https://www.thieme-connect.de/lockss.txt
            if (defined($man_contents) && ($man_contents =~ m/Year $param{volume_name}/) && ($man_contents =~ m/DOI: $doi/)) {
                if ($man_contents =~ m/<h1>(.*)<\/h1>/si) {
                    $vol_title = $1
                }
                $result = "Manifest"
            } else {
                $result = "--"
            }
        } else {
            $result = "--"
        }
        sleep(4);

  } elsif ($plugin eq "ClockssGeorgThiemeVerlagPlugin") {
        #Url with list of urls for issues
        #printf("%s\n",decode_entities($tmp));
        $url = sprintf("%sejournals/issues/%s/%s",
          $param{base_url}, $param{journal_id}, $param{volume_name});
        $man_url = uri_unescape($url);
        my $doi = uri_unescape($param{journal_id});
        my $req = HTTP::Request->new(GET, $man_url);
        my $resp = $ua->request($req);
        if ($resp->is_success) {
            my $man_contents = $resp->content;
            if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/Year $param{volume_name}/) && ($man_contents =~ m/DOI: $doi/)) {
                if ($man_contents =~ m/<h1>(.*)<\/h1>/si) {
                    $vol_title = $1
                }
                $result = "Manifest"
            } else {
                $result = "--"
            }
        } else {
            $result = "--"
        }
        sleep(4);

  } elsif (($plugin eq "TaylorAndFrancisPlugin") ||
           ($plugin eq "GenericAtyponPlugin") ||
           ($plugin eq "AIAAPlugin") ||
           ($plugin eq "AllenPressJournalsPlugin") ||
           ($plugin eq "AmPublicHealthAssocPlugin") ||
           ($plugin eq "AMetSocPlugin") ||
           ($plugin eq "ARRSPlugin") ||
           ($plugin eq "BIRAtyponPlugin") ||
           ($plugin eq "EdinburghUniversityPressPlugin") ||
           ($plugin eq "EmeraldGroupPlugin") ||
           ($plugin eq "EndocrineSocietyPlugin") ||
           ($plugin eq "FutureSciencePlugin") ||
           ($plugin eq "IndersciencePlugin") ||
#           ($plugin eq "JstorPlugin") ||
           ($plugin eq "LiverpoolJournalsPlugin") ||
#           ($plugin eq "ManeyAtyponPlugin") ||
           ($plugin eq "MarkAllenPlugin") ||
           ($plugin eq "MultiSciencePlugin") ||
           ($plugin eq "MassachusettsMedicalSocietyPlugin") ||
           ($plugin eq "SageAtyponJournalsPlugin") ||
           ($plugin eq "SiamPlugin") ||
           ($plugin eq "WageningenJournalsPlugin")) {
      $url = sprintf("%slockss/%s/%s/index.html",
      $param{base_url}, $param{journal_id}, $param{volume_name});
      $man_url = uri_unescape($url);
      my $req = HTTP::Request->new(GET, $man_url);
      my $resp = $ua->request($req);
      if ($resp->is_success) {
          my $man_contents = $resp->content;
          #JSTOR plugin links are like ?journalCode=chaucerrev&amp;issue=2&amp;volume=44
          if ($req->url ne $resp->request->uri) {
              $vol_title = $resp->request->uri;
              $result = "Redirected";
          } elsif (defined($man_contents) && (($man_contents =~ m/$lockss_tag/) && 
                  (($man_contents =~ m/$param{journal_id}\/$param{volume_name}\//) || 
                  ($man_contents =~ m/\/toc\/$param{journal_id}\/*$param{volume_name}\"/) || 
                  ($man_contents =~ m/$param{journal_id}\S*volume=$param{volume_name}/)))) {
              if ($man_contents =~ m/<title>\s*(.*) LOCKSS Manifest Page\s*<\/title>/si) {
                  $vol_title = $1;
                  $vol_title =~ s/\s*\n\s*/ /g;
                  $vol_title =~ s/ &amp\; / & /;
                  if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                      $vol_title = "\"" . $vol_title . "\"";
                  }
              }
              $result = "Manifest";
          } else {
              $result = "--"
          }
      } else {
          $result = "--"
      }
        sleep(4);

  } elsif (($plugin eq "ClockssTaylorAndFrancisPlugin") ||
           ($plugin eq "ClockssGenericAtyponPlugin") ||
           ($plugin eq "ClockssAIAAPlugin") ||
           ($plugin eq "ClockssAllenPressJournalsPlugin") ||
           ($plugin eq "ClockssAMetSocPlugin") ||
           ($plugin eq "ClockssAmmonsScientificPlugin") ||
           ($plugin eq "ClockssASCEPlugin") ||
           ($plugin eq "ClockssBIRAtyponPlugin") ||
           ($plugin eq "ClockssFutureSciencePlugin") ||
           ($plugin eq "ClockssEdinburghUniversityPressPlugin") ||
           ($plugin eq "ClockssEmeraldGroupPlugin") ||
           ($plugin eq "ClockssEndocrineSocietyPlugin") ||
           ($plugin eq "ClockssIndersciencePlugin") ||
#           ($plugin eq "ClockssJstorPlugin") ||
           ($plugin eq "ClockssLiverpoolJournalsPlugin") ||
#           ($plugin eq "ClockssManeyAtyponPlugin") ||
           ($plugin eq "ClockssMarkAllenPlugin") ||
           ($plugin eq "ClockssMultiSciencePlugin") ||
           ($plugin eq "ClockssNRCResearchPressPlugin") ||
           ($plugin eq "ClockssPracticalActionJournalsPlugin") ||
           ($plugin eq "ClockssSageAtyponJournalsPlugin") ||
           ($plugin eq "ClockssSEGPlugin") ||
           ($plugin eq "ClockssSiamPlugin") ||
           ($plugin eq "ClockssWageningenJournalsPlugin")) {
      $url = sprintf("%sclockss/%s/%s/index.html",
      $param{base_url}, $param{journal_id}, $param{volume_name});
      $man_url = uri_unescape($url);
      my $req = HTTP::Request->new(GET, $man_url);
      my $resp = $ua->request($req);
      if ($resp->is_success) {
          my $man_contents = $resp->content;
          #JSTOR plugin links are like ?journalCode=chaucerrev&amp;issue=2&amp;volume=44
          if ($req->url ne $resp->request->uri) {
              $vol_title = $resp->request->uri;
              $result = "Redirected";
          } elsif (defined($man_contents) && (($man_contents =~ m/$clockss_tag/) && 
                  (($man_contents =~ m/$param{journal_id}\/$param{volume_name}\//) || 
                  ($man_contents =~ m/\/toc\/$param{journal_id}\/*$param{volume_name}\"/) || 
                  ($man_contents =~ m/$param{journal_id}\S*volume=$param{volume_name}/)))) {
              if ($man_contents =~ m/<title>\s*(.*) CLOCKSS Manifest Page\s*<\/title>/si) {
                  $vol_title = $1;
                  $vol_title =~ s/\s*\n\s*/ /g;
                  $vol_title =~ s/ &amp\; / & /;
                  if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                      $vol_title = "\"" . $vol_title . "\"";
                  }
              }
              $result = "Manifest";
          } else {
              $result = "--"
          }
      } else {
      $result = "--"
  }
        sleep(4);

  # the non-Clockss Atypon Books plugins go here
  } elsif (($plugin eq "GenericAtyponBooksPlugin") ||
           ($plugin eq "AIAABooksPlugin") ||
           ($plugin eq "EmeraldGroupBooksPlugin") ||
           ($plugin eq "EndocrineSocietyBooksPlugin") ||
           ($plugin eq "FutureScienceBooksPlugin") ||
           ($plugin eq "LiverpoolBooksPlugin") ||
           ($plugin eq "SiamBooksPlugin") ||
           ($plugin eq "WageningenBooksPlugin")) {
      $url = sprintf("%slockss/eisbn/%s",
      $param{base_url}, $param{book_eisbn});
      $man_url = uri_unescape($url);
      my $req = HTTP::Request->new(GET, $man_url);
      my $resp = $ua->request($req);
      if ($resp->is_success) {
          my $man_contents = $resp->content;
          if ($req->url ne $resp->request->uri) {
              $vol_title =  $resp->request->uri;
              $result = "Redirected";
          } elsif (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
              #prepare for the worst by presetting a not found result...
              $result = "--";
              if ($man_contents =~ m/doi\/book\/([^\/]+)\/([^"']+)/) {
                  my $doi1 = $1;
                  my $doi2 = $2;
                  #get the title of the book if we found the manifest page
                  if ($man_contents =~ m/<title>(.*) Manifest Page<\/title>/si) {
                      $vol_title = $1;
                      $vol_title =~ s/\s*\n\s*/ /g;
                      $vol_title =~ s/ &amp\; / & /;
                      if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                          $vol_title = "\"" . $vol_title . "\"";
                      }
                  }
                  # now make sure a PDF is actually available on the book landing page
                  # whole book pdf will use the same doi as the book landing page
                  $url = sprintf("%sdoi/book/%s/%s",$param{base_url}, $doi1, $doi2);
                  my $book_url = uri_unescape($url);
                  my $breq = HTTP::Request->new(GET, $book_url);
                  my $bresp = $ua->request($breq);
                  if ($bresp->is_success) {
                      my $b_contents = $bresp->content;
                      # what we're looking for on the page is href="/doi/pdf/doi1/doi2" OR href="/doi/pdfplus/doi1/doi2
                      #printf("href=\"pdfplus/%s/%s\"",${doi1},${doi2});
                      #if (defined($b_contents) && ($b_contents =~ m/href=\"[^"]+pdf(plus)?\/${doi1}\/${doi2}/)) {
                      if (defined($b_contents) && ($b_contents =~ m/href=\"[^"]+pdf(plus)?\/${doi1}\//)) {
                          $result = "Manifest";
                      }
                  } 
              }
          } else {
              $result = "--"
          }
      } else {
          $result = "--"
      }
        sleep(4);

  # the CLOCKSS Atypon Books plugins go here
  } elsif (($plugin eq "ClockssGenericAtyponBooksPlugin") ||
           ($plugin eq "ClockssAIAABooksPlugin") ||
           ($plugin eq "ClockssEmeraldGroupBooksPlugin") ||
           ($plugin eq "ClockssEndocrineSocietyBooksPlugin") ||
           ($plugin eq "ClockssFutureScienceBooksPlugin") ||
           ($plugin eq "ClockssLiverpoolBooksPlugin") ||
           ($plugin eq "ClockssNRCResearchPressBooksPlugin") ||
           ($plugin eq "ClockssSEGBooksPlugin") ||
           ($plugin eq "ClockssSiamBooksPlugin") ||
           ($plugin eq "ClockssPracticalActionBooksPlugin") ||
           ($plugin eq "ClockssWageningenBooksPlugin")) {
      $url = sprintf("%sclockss/eisbn/%s",
      $param{base_url}, $param{book_eisbn});
      $man_url = uri_unescape($url);
      my $req = HTTP::Request->new(GET, $man_url);
      my $resp = $ua->request($req);
      if ($resp->is_success) {
          my $man_contents = $resp->content;
          if ($req->url ne $resp->request->uri) {
              $vol_title =  $resp->request->uri;
              $result = "Redirected";
          } elsif (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
              #prepare for the worst by presetting a not found result...
              $result = "--";
              if ($man_contents =~ m/doi\/book\/([^\/]+)\/([^"']+)/) {
                  my $doi1 = $1;
                  my $doi2 = $2;
                  #get the title of the book if we found the manifest page
                  if ($man_contents =~ m/<title>(.*) Manifest Page<\/title>/si) {
                      $vol_title = $1;
                      $vol_title =~ s/\s*\n\s*/ /g;
                      $vol_title =~ s/ &amp\; / & /;
                      if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
                          $vol_title = "\"" . $vol_title . "\"";
                      }
                  }
                  # now make sure a PDF is actually available on the book landing page
                  # whole book pdf will use the same doi as the book landing page
                  $url = sprintf("%sdoi/book/%s/%s",$param{base_url}, $doi1, $doi2);
                  my $book_url = uri_unescape($url);
                  my $breq = HTTP::Request->new(GET, $book_url);
                  my $bresp = $ua->request($breq);
                  if ($bresp->is_success) {
                      my $b_contents = $bresp->content;
                      # what we're looking for on the page is href="/doi/pdf/doi1/doi2" OR href="/doi/pdfplus/doi1/doi2
                      #printf("href=\"pdfplus/%s/%s\"",${doi1},${doi2});
                      #if (defined($b_contents) && ($b_contents =~ m/href=\"[^"]+pdf(plus)?\/${doi1}\/${doi2}/)) {
                      if (defined($b_contents) && ($b_contents =~ m/href=\"[^"]+pdf(plus)?\/${doi1}\//)) {
                          $result = "Manifest";
                      }
                  }
              }
          } else {
              $result = "--"
          }
      } else {
          $result = "--"
      }
        sleep(4);

#  } elsif ($plugin eq "EdinburghUniversityPressPlugin") {
#    $url = sprintf("%slockss/%s/%s/index.html",
#      $param{base_url}, $param{journal_id}, $param{volume_name});
#    $man_url = uri_unescape($url);
#    #printf("\nUrl: %s\n", $man_url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && (($man_contents =~ m/$lockss_tag/) || ($man_contents =~ m/$oa_tag/)) && ($man_contents =~ m/\/$param{journal_id}\//)) {
#        if ($man_contents =~ m/<title>(.*)LOCKSS Manifest Page<\/title>/si) {
#          $vol_title = $1;
#          $vol_title =~ s/\s*\n\s*/ /g;
#          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
#            $vol_title = "\"" . $vol_title . "\"";
#          }
#        }
#        $result = "Manifest";
#      } else {
#        $result = "--"
#      }
#    } else {
#      $result = "--"
#    }
#    sleep(4);
#
#  } elsif ($plugin eq "ClockssEdinburghUniversityPressPlugin") {
#    $url = sprintf("%sclockss/%s/%s/index.html",
#      $param{base_url}, $param{journal_id}, $param{volume_name});
#    $man_url = uri_unescape($url);
#    #printf("\nUrl: %s\n", $man_url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/\/$param{journal_id}\//)) {
#        if ($man_contents =~ m/<title>(.*)CLOCKSS Manifest Page<\/title>/si) {
#          $vol_title = $1;
#          $vol_title =~ s/\s*\n\s*/ /g;
#          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
#            $vol_title = "\"" . $vol_title . "\"";
#          }
#        }
#        $result = "Manifest";
#      } else {
#        $result = "--"
#      }
#    } else {
#      $result = "--"
#    }
#    sleep(4);

  } elsif ($plugin eq "ClockssAmericanMathematicalSocietyPlugin") {
    $url = sprintf("%sclockssdata/?p=%s&y=%d",
      $param{base_url}, $param{journal_id}, $param{year});
    $man_url = uri_unescape($url);
    #printf("\nUrl: %s\n", $man_url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
        $vol_title = $param{journal_id};
        if (($man_contents =~ m/\/$param{journal_id}\//) && ($man_contents =~ m/$param{year}/)) {
          $result = "Manifest";
        } else {
          $result = "--NO_URL--";
        }
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

  } elsif ($plugin eq "MathematicalSciencesPublishersPlugin") {
    $url = sprintf("%s%s/%d/manifest",
      $param{base_url}, $param{journal_id}, $param{year});
    $man_url = uri_unescape($url);
    #printf("\nUrl: %s\n", $man_url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/) && ($man_contents =~ m/\/$param{journal_id}\/$param{year}/)) {
        $vol_title = $param{journal_id};
        $result = "Manifest";
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssMathematicalSciencesPublishersPlugin") {
    $url = sprintf("%s%s/%d/manifest",
      $param{base_url}, $param{journal_id}, $param{year});
    $man_url = uri_unescape($url);
    #printf("\nUrl: %s\n", $man_url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/\/$param{journal_id}\/$param{year}/)) {
        $vol_title = $param{journal_id};
        $result = "Manifest";
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

#  } elsif ($plugin eq "ClockssPionPlugin") {
#    $url = sprintf("%scontents.cgi?journal=%s&amp;volume=%s",
#      $param{base_url}, $param{short_journal_code}, $param{volume_name});
#    $man_url = uri_unescape($url);
#    #printf("\nUrl: %s\n", $man_url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/href=.abstract\.cgi\?id=/)) {
#        if ($man_contents =~ m/<title>(.*)<\/title>/si) {
#          $vol_title = $1;
#          $vol_title =~ s/\s*\n\s*/ /g;
#          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
#            $vol_title = "\"" . $vol_title . "\"";
#          }
#        }
#        $result = "Manifest";
#      } else {
#        $result = "--"
#      }
#    } else {
#      $result = "--"
#    }
#    sleep(4);
#
  } elsif ($plugin eq "MaffeyPlugin") {
    $url = sprintf("%slockss.php?t=lockss&pa=issue&j_id=%s&year=%d",
      $param{base_url}, $param{journal_id}, $param{year});
    $man_url = uri_unescape($url);
    #printf("\nUrl: %s\n", $man_url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/ || $man_contents =~ m/$oa_tag/) && ($man_contents =~ m/a href=.lockss.php/)) {
        if ($man_contents =~ m/<title>LOCKSS - Published Issues: (.*)<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest";
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssMaffeyPlugin") {
    $url = sprintf("%slockss.php?t=clockss&pa=issue&j_id=%s&year=%d",
      $param{base_url}, $param{journal_id}, $param{year});
    $man_url = uri_unescape($url);
    #printf("\nUrl: %s\n", $man_url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/a href=.lockss.php/)) {
        if ($man_contents =~ m/<title>CLOCKSS - Published Issues: (.*)<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest";
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

  } elsif ($plugin eq "BioOneAtyponPlugin") {
    $url = sprintf("%slockss/%s/%s/index.html",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && (($man_contents =~ m/$lockss_tag/) || ($man_contents =~ m/$oa_tag/))) {
        if ($man_contents =~ m/<title>(.*)\s*LOCKSS Manifest Page<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssBioOneAtyponPlugin") {
    $url = sprintf("%sclockss/%s/%s/index.html",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
        if ($man_contents =~ m/<title>(.*)\s*CLOCKSS Manifest Page<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

#  } elsif ($plugin eq "PortlandPressPlugin") {
#    $url = sprintf("%s%s/%s/lockss.htm",
#      $param{base_url}, $param{journal_id}, $param{volume_name});
#    $man_url = uri_unescape($url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
#        $result = "Manifest"
#      } else {
#        $result = "--"
#      }
#    } else {
#      $result = "--"
#    }
#    sleep(4);
#
#  } elsif ($plugin eq "ClockssPortlandPressPlugin") {
#    $url = sprintf("%s%s/%s/lockss.htm",
#      $param{base_url}, $param{journal_id}, $param{volume_name});
#    $man_url = uri_unescape($url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
#        $result = "Manifest"
#      } else {
#        $result = "--"
#      }
#    } else {
#      $result = "--"
#    }
#    sleep(4);
#
  } elsif ($plugin eq "ClockssNaturePublishingGroupPlugin") {
    $url = sprintf("%s%s/clockss/%s_clockss_%d.html",
      $param{base_url}, $param{journal_id}, $param{journal_id}, $param{year});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && (($man_contents =~ m/\/$param{journal_id}\/journal\/v$param{volume_name}/) || ($man_contents =~ m/\/$param{journal_id}\/archive\//) || ($man_contents =~ m/\/$param{journal_id}\/index_ja.html/))) {
        if ($man_contents =~ m/<TITLE>\s*(.*)\s*<\/TITLE>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssPalgraveBookPlugin") {
    $url = sprintf("%spc/doifinder/10.1057/%s",
      $param{base_url}, $param{book_isbn});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/\/download\/10.1057\/$param{book_isbn}(\.pdf|\.epub|\")/)) {
        if ($man_contents =~ m/<h1 class="product-title"\s*>\s*([^<>]*)\s*<\/h1>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          $vol_title =~ s/\s*<br \/>\s*/: /;
          $vol_title =~ s/<\/?span>//g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);

  } elsif ($plugin eq "IngentaJournalPlugin") {
    $url = sprintf("%scontent/%s?format=lockss&volume=%s",
      $param{base_url}, $param{journal_issn}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/) && ($man_contents =~ m/<a href="[^"]*$param{volume_name}/)) {
        if ($man_contents =~ m/<TITLE>\s*(.*)\s*<\/TITLE>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);
  } elsif ($plugin eq "ClockssIngentaJournalPlugin") {
    $url = sprintf("%scontent/%s?format=clockss&volume=%s",
      $param{base_url}, $param{journal_issn}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/<a href="[^"]*$param{volume_name}/)) {
        if ($man_contents =~ m/<TITLE>\s*(.*)\s*<\/TITLE>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--"
      }
    } else {
      $result = "--"
    }
    sleep(4);
#  } elsif ($plugin eq "MetaPressPlugin") {
#    $url = sprintf("%sopenurl.asp?genre=volume&eissn=%s&volume=%s",
#      $param{base_url}, $param{journal_issn}, $param{volume_name});
#    $man_url = uri_unescape($url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/) && ($man_contents =~ m/genre=volume&amp;eissn=$param{journal_issn}&amp;volume=$param{volume_name}/)) {
#        if ($man_contents =~ m/<td class=.labelName.>Journal<\/td><td class=.labelValue.><a href=\"\S*\">([^<]*)<\/a>\s*<\/td>/si) {
#          $vol_title = $1;
#          $vol_title =~ s/\s*\n\s*/ /g;
#          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
#            $vol_title = "\"" . $vol_title . "\"";
#          }
#        }
#        $result = "Manifest"
#      } else {
#        $result = "--NO_TAG--"
#      }
#    } else {
#      $result = "--REQ_FAIL--"
#    }
#    sleep(4);
#  } elsif ($plugin eq "ClockssMetaPressPlugin") {
#    $url = sprintf("%sopenurl.asp?genre=volume&eissn=%s&volume=%s",
#      $param{base_url}, $param{journal_issn}, $param{volume_name});
#    $man_url = uri_unescape($url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/genre=volume&amp;eissn=$param{journal_issn}&amp;volume=$param{volume_name}/)) {
#        if ($man_contents =~ m/<td class=.labelName.>Journal<\/td><td class=.labelValue.><a href=\"\S*\">([^<]*)<\/a>\s*<\/td>/si) {
#          $vol_title = $1;
#          $vol_title =~ s/\s*\n\s*/ /g;
#          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
#            $vol_title = "\"" . $vol_title . "\"";
#          }
#        }
#        $result = "Manifest"
#      } else {
#        $result = "--NO_TAG--"
#      }
#    } else {
#      $result = "--REQ_FAIL--"
#    }
#    sleep(4);
  } elsif ($plugin eq "BloomsburyQatarPlugin") {
    $url = sprintf("%slockss/%s/%s/index.html",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
      if ($man_contents =~ m/<title>\s*(.*)\s*LOCKSS Manifest Page\s*<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);
  } elsif ($plugin eq "ClockssBloomsburyQatarPlugin") {
    $url = sprintf("%sclockss/%s/%s/index.html",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if ($man_contents =~ m/<title>\s*(.*)\s*CLOCKSS Manifest Page\s*<\/title>/si) {
        if ($man_contents =~ m/<tr>\s*<td class=.labelName.>Journal<\/td><td class=.labelValue.><a href=\"\S*\">(.*)<\/a>\s*<\/td>\s*<\/tr>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);
  } elsif ($plugin eq "ClockssIOPSciencePlugin") {
    $url = sprintf("%s%s/%s",
      $param{base_url}, $param{journal_issn}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
        if ($man_contents =~ m/<TITLE>\s*(.*)\s*<\/TITLE>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "IgiGlobalPlugin") {
    $url = sprintf("%slockss/journal-issues.aspx?issn=%s&volume=%s",
      $param{base_url}, $param{journal_issn}, $param{volume});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/) && ($man_contents =~ m/$igi_tag/)) {
        if ($man_contents =~ m/<TITLE>\s*(.*)\s*<\/TITLE>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssIgiGlobalPlugin") {
    $url = sprintf("%slockss/journal-issues.aspx?issn=%s&volume=%s",
      $param{base_url}, $param{journal_issn}, $param{volume});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/$igi_tag/)) {
        if ($man_contents =~ m/<TITLE>\s*(.*)\s*<\/TITLE>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

#  } elsif ($plugin eq "ClockssRoyalSocietyOfChemistryPlugin") {
#    $url = sprintf("%spublishing/journals/lockss/?journalcode=%s&volume=%s&year=%d",
#      $param{base_url}, $param{journal_code}, $param{volume_name}, $param{year});
#    $man_url = uri_unescape($url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
#        if ($man_contents =~ m/<title>\s*(.*)\s*<\/title>/si) {
#          $vol_title = $1;
#          $vol_title =~ s/\s*\n\s*/ /g;
#          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
#            $vol_title = "\"" . $vol_title . "\"";
#          }
#        }
#        $result = "Manifest"
#      } else {
#        $result = "--NO_TAG--"
#      }
#    } else {
#      $result = "--REQ_FAIL--"
#    }
#    sleep(4);
#
  } elsif ($plugin eq "RSC2014Plugin") {
    $url = sprintf("%sen/journals/lockss?journalcode=%s&volume=%s&year=%d",
      $param{base_url}, $param{journal_code}, $param{volume_name}, $param{year});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/) && ($man_contents =~ m/\/lockss\?journalcode=$param{journal_code}&volume=$param{volume_name}&year=$param{year}/)) {
        if ($man_contents =~ m/<title>\s*RSC Journals \|(.*)\s*<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssRSC2014Plugin") {
    $url = sprintf("%sen/journals/lockss?journalcode=%s&volume=%s&year=%d",
      $param{base_url}, $param{journal_code}, $param{volume_name}, $param{year});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/\/lockss\?journalcode=$param{journal_code}&volume=$param{volume_name}&year=$param{year}/)) {
        if ($man_contents =~ m/<title>\s*RSC Journals \|(.*)\s*<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  #American Society for Microbiology Books
  } elsif ($plugin eq "ClockssASMscienceBooksPlugin") {
    $url = sprintf("%scontent/book/%s",
      $param{base_url}, $param{doi});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      my $has_no_chapters = "Chapters \\(0\\)";
      if ($man_contents =~ m/$has_no_chapters/ ) {
	print "matches - has no chapters\n";
      } else {
	print "no match -has chapters\n";
      }
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents !~ m/$has_no_chapters/)) {
        if ($man_contents =~ m/<title>\s*ASMscience \|(.*)\s*<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  # Clockss Microbiology Society
  } elsif ($plugin eq "ClockssMicrobiologySocietyJournalsPlugin") {
    $url = sprintf("%scontent/journal/%s/clockssissues?volume=%s",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "MicrobiologySocietyJournalsPlugin") {
    $url = sprintf("%scontent/journal/%s/lockssissues?volume=%s",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "ASMscienceJournalsPlugin") {
    $url = sprintf("%scontent/journal/%s/lockssissues?volume=%s",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssASMscienceJournalsPlugin") {
    $url = sprintf("%scontent/journal/%s/clockssissues?volume=%s",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif (($plugin eq "ClockssCopernicusPublicationsPlugin") ||
           ($plugin eq "CopernicusPublicationsPlugin"))  {
    $url_p = sprintf("%s",
      $param{home_url});
    $url_s = sprintf("%s%s/index.html",
      $param{base_url}, $param{volume_name});
    $url_d = sprintf("%s%s/",
      $param{base_url}, $param{volume_name});
    $man_url = uri_unescape($url_s) . " + " . uri_unescape($url_p) ;
    $man_url_p = uri_unescape($url_p);
#    printf("*man_url_p: %s\n", $man_url_p);
    $man_url_s = uri_unescape($url_s);
#    printf("*man_url_s: %s\n", $man_url_s);
    my $article_prefix = uri_unescape($url_d);
#    printf("*article_prefix: %s\n", $article_prefix);
    my $req_p = HTTP::Request->new(GET, $man_url_p);
    my $req_s = HTTP::Request->new(GET, $man_url_s);
    my $resp_p = $ua->request($req_p);
    my $resp_s = $ua->request($req_s);
    if ($resp_p->is_success && $resp_s->is_success) {
      my $perm_contents = $resp_p->content;
      my $start_contents = $resp_s->content;
      if ((defined($perm_contents)) && 
          (defined($start_contents)) && 
          ($start_contents =~ m/$article_prefix/) && 
          ($perm_contents =~ m/$cc_license_tag/) && 
          ($perm_contents =~ m/$cc_license_url/)) {
        if ($perm_contents =~ m/j-name.>\s*([^<]*)\s*<\//si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

#  } elsif ($plugin eq "CopernicusPublicationsPlugin") {
#    $url_p = sprintf("%s",
#      $param{home_url});
#    $url_s = sprintf("%s%s/index.html",
#      $param{base_url}, $param{volume_name});
#    $url_d = sprintf("%s%s/",
#      $param{base_url}, $param{volume_name});
#    $man_url = uri_unescape($url_s) . " + " . uri_unescape($url_p) ;
#    $man_url_p = uri_unescape($url_p);
##    printf("*man_url_p: %s\n", $man_url_p);
#    $man_url_s = uri_unescape($url_s);
##    printf("*man_url_s: %s\n", $man_url_s);
#    my $article_prefix = uri_unescape($url_d);
##    printf("*article_prefix: %s\n", $article_prefix);
#    my $req_p = HTTP::Request->new(GET, $man_url_p);
#    my $req_s = HTTP::Request->new(GET, $man_url_s);
#    my $resp_p = $ua->request($req_p);
#    my $resp_s = $ua->request($req_s);
#    if ($resp_p->is_success && $resp_s->is_success) {
#      my $perm_contents = $resp_p->content;
#      my $start_contents = $resp_s->content;
#      if (defined($perm_contents) && defined($start_contents) && 
#         ($start_contents =~ m/$param{base_url}$param{volume_name}\//) && 
#         (($perm_contents =~ m/$lockss_tag/) || (($perm_contents =~ m/$cc_license_tag/) && ($perm_contents =~ m/$cc_license_url/)) )) {
#        if ($perm_contents =~ m/j-name.>\s*([^<]*)\s*<\//si) {
#          $vol_title = $1;
#          $vol_title =~ s/\s*\n\s*/ /g;
#          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
#            $vol_title = "\"" . $vol_title . "\"";
#          }
#        }
#        $result = "Manifest"
#      } else {
#        $result = "--NO_TAG--"
#      }
#    } else {
#      $result = "--REQ_FAIL--"
#    }
#    sleep(4);

  } elsif (($plugin eq "BMCPlugin") || ($plugin eq "ClockssBMCPlugin")) {
    $url = sprintf("%s%s/%s",
      $param{base_url}, $param{journal_issn}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$bmc_tag/) && ($man_contents =~ m/content\/$param{volume_name}/)) {
        if ($man_contents =~ m/<title>(.*)<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/ \| / /g;
          $vol_title =~ s/2013/Volume $param{volume_name}/g;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif (($plugin eq "BioMedCentralPlugin") || ($plugin eq "ClockssBioMedCentralPlugin")) {
    $url = sprintf("%scontent/%s",
      $param{base_url}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && (($man_contents =~ m/$bmc_tag/) || ($man_contents =~ m/$bmc2_tag/)) && ($man_contents =~ m/content\/$param{volume_name}/)) {
        if ($man_contents =~ m/<title>(.*)<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/ \| / /g;
          $vol_title =~ s/\s*\n\s*/ /g;
          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
            $vol_title = "\"" . $vol_title . "\"";
          }
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif (($plugin eq "HindawiPublishingCorporationPlugin") || ($plugin eq "ClockssHindawiPublishingCorporationPlugin")) {
    $url = sprintf("%sjournals/%s/%s/",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/journals\/$param{journal_id}\/$param{volume_name}/)) {
        if ($man_contents =~ m/<title>(.*)<\/title>/si) {
          $vol_title = $1;
          #$vol_title =~ s/ \| / /g;
          $vol_title =~ s/\s*\n\s*/ /g;
          $vol_title =~ s/An Open Access Journal//;
          $vol_title =~ s/\s+/ /g;
          $vol_title =~ s/&#8212;/Volume $param{volume_name}/g;

        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif (($plugin eq "MedknowPlugin") || ($plugin eq "ClockssMedknowPlugin")) {
    $url = sprintf("%sbackissues.asp",
      $param{base_url});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      #showBackIssue.asp?issn=0189-6725;year=2015;volume=12
      #showBackIssue.asp?issn=0022-3859;year=2016;volume=62
      #showBackIssue.asp?issn=$param{journal_issn};year=$param{year};volume=$param{volume_name}
      if (defined($man_contents) && ($man_contents =~ m/showBackIssue.asp\?issn=$param{journal_issn};year=$param{year};volume=$param{volume_name}/)) {
        if ($man_contents =~ m/<title>(.*)<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          $vol_title =~ s/\s+/ /g;
          $vol_title =~ s/: Table of Contents?/ Volume $param{volume_name}/i;
        }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

#  } elsif ($plugin eq "EmeraldPlugin") {
#    $url = sprintf("%scrawlers/lockss.htm?issn=%s&volume=%s",
#      $param{base_url}, $param{journal_issn}, $param{volume_name});
#    $man_url = uri_unescape($url);
#    my $req = HTTP::Request->new(GET, $man_url);
#    my $resp = $ua->request($req);
#    if ($resp->is_success) {
#      my $man_contents = $resp->content;
#      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/) && ($man_contents =~ m/crawlers\/lockss.htm\?issn=$param{journal_issn}&amp;volume=$param{volume_name}/)) {
#        if ($man_contents =~ m/<strong>Journal title:<\/strong>(.*)<br \/>/si) {
#          $vol_title = $1 . " Volume " . $param{volume_name};
#          $vol_title =~ s/\s*\n\s*/ /g;
#          if (($vol_title =~ m/</) || ($vol_title =~ m/>/)) {
#            $vol_title = "\"" . $vol_title . "\"";
#          }
#        }
#        $result = "Manifest"
#      } else {
#        $result = "--NO_TAG--"
#      }
#    } else {
#      $result = "--REQ_FAIL--"
#    }
#    sleep(4);
#
  } elsif ($plugin eq "ACSESSJournalsPlugin") {
    $url = sprintf("%spublications/%s/tocs/%s",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/) && ($man_contents =~ m/\/publications\/$param{journal_id}\/tocs\/$param{volume_name}\//)) {
        if ($man_contents =~ m/<title>(.*)<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/ \| Digital Library//;
          $vol_title =~ s/ - / /;
          $vol_title =~ s/ &amp\; / & /;
          }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssACSESSJournalsPlugin") {
    $url = sprintf("%spublications/%s/tocs/%s",
      $param{base_url}, $param{journal_id}, $param{volume_name});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/) && ($man_contents =~ m/\/publications\/$param{journal_id}\/tocs\/$param{volume_name}\//)) {
        if ($man_contents =~ m/<title>(.*)<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/ \| Digital Library//;
          $vol_title =~ s/ - / /;
          $vol_title =~ s/ &amp\; / & /;
          }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "SilverchairJournalsPlugin") {
    $url = sprintf("%sLOCKSS/ListOfIssues.aspx?resourceId=%d&year=%d",
      $param{base_url}, $param{resource_id}, $param{year});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssSilverchairJournalsPlugin") {
    $url = sprintf("%sLOCKSS/ListOfIssues.aspx?resourceId=%d&year=%d",
      $param{base_url}, $param{resource_id}, $param{year});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "SilverchairProceedingsPlugin") {
    $url = sprintf("%sLOCKSS/ListOfVolumes.aspx?year=%d",
      $param{base_url}, $param{year});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
      	$vol_title= "Proceedings for " . $param{year};
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssSilverchairProceedingsPlugin") {
    $url = sprintf("%sLOCKSS/ListOfVolumes.aspx?year=%d",
      $param{base_url}, $param{year});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
      	$vol_title= "Proceedings for " . $param{year};
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "SilverchairBooksPlugin") {
    $url = sprintf("%sbook.aspx?bookid=%d",
      $param{base_url}, $param{resource_id});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$lockss_tag/)) {
      if ($man_contents =~ m/<title>(.*)<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          }
        $result = "Manifest"
     } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);

  } elsif ($plugin eq "ClockssSilverchairBooksPlugin") {
    $url = sprintf("%sbook.aspx?bookid=%d",
      $param{base_url}, $param{resource_id});
    $man_url = uri_unescape($url);
    my $req = HTTP::Request->new(GET, $man_url);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
      my $man_contents = $resp->content;
      if (defined($man_contents) && ($man_contents =~ m/$clockss_tag/)) {
      if ($man_contents =~ m/<title>(.*)<\/title>/si) {
          $vol_title = $1;
          $vol_title =~ s/\s*\n\s*/ /g;
          }
        $result = "Manifest"
      } else {
        $result = "--NO_TAG--"
      }
    } else {
      $result = "--REQ_FAIL--"
    }
    sleep(4);
  }

  if($result eq "Plugin Unknown") {
    printf("*PLUGIN UNKNOWN*, %s, %s\n",$auid,$man_url);
    $total_missing_plugin = $total_missing_plugin + 1;
  } elsif ($result eq "Manifest") {
    printf("*MANIFEST*, %s, %s, %s\n",$vol_title,$auid_long,$man_url);
    $total_manifests = $total_manifests + 1;
    #printf("%s\n",$vol_title);
    #printf("%s\n",decode_entities($vol_title));
    #my $new_title = encode("utf8", $vol_title);
    #printf("%s\n",$new_title);
    #printf("%s\n",decode_entities($new_title));
  } else {
    printf("*NO MANIFEST*(%s), %s, %s, %s\n",$result,$vol_title,$auid,$man_url);
    $total_missing = $total_missing + 1;
    #$tmp = "AINS - An&auml;sthesiologie &middot; Intensivmedizin &middot; Notfallmedizin &middot; Schmerztherapie";
    #printf("%s\n",$tmp);
    #printf("%s\n",decode_entities($tmp));
  }
}
printf("*Today: %s\n", $datestring);
printf("*Total manifests found: %d\n", $total_manifests);
printf("*Total missing manifests: %d\n", $total_missing);
printf("*Total AUs with unknown plugin: %d\n", $total_missing_plugin);
exit(0);
