%define node_id XXX
%define node_spec_version 1.0

%define jdg_version XXX

%define jdg_home XXX

%define username XXX
%define group XXX

Name:	    jdg-node%{node_id}
Version:	%{node_spec_version}
Release:	1%{?dist}
Summary:    Set up instance %{node_id} of JBoss Data Grid

Group:      Administration
License:	GPL
URL:        http://access.redhat.com/

Packager:   Romain Pelisse
BuildArch:  noarch

Requires(pre): shadow-utils, jdg

%pre
exit 0

%post

mkdir -p /etc/jdg
sed -e "s;\(export NODE_ID=\).*$;\1'%{node_id}';g" \
    -e "s;\(export JBOSS_HOME=\).*$;\1'%{jdg_home}';g" \
    -e "s;\(export JBOSS_USER=\).*$;\1'%{username}';g" \
    %{jdg_home}/bin/init.d/jboss-as.conf > /etc/jdg/node-%{node_id}.conf
ln -s %{jdg_home}/bin/init.d/jdg /etc/init.d/jdg-node-%{node_id}

%clean
exit 0

%description

%files

%doc


%changelog

