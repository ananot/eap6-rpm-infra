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

Requires(pre): jdg

%pre
exit 0

%post

mkdir -p /etc/jdg
sed -e "s;\(export NODE_ID=\).*$;\1'%{node_id}';g" \
    -e "s;\(export JBOSS_HOME=\).*$;\1'%{jdg_home}';g" \
    -e "s;\(export JBOSS_USER=\).*$;\1'%{username}';g" \
    %{jdg_home}/bin/init.d/jboss-as.conf > /etc/jdg/node-%{node_id}.conf

%define service_name /etc/init.d/jdg-node-%{node_id}
if [ ! -L %{service_name} ]; then
  ln -s %{jdg_home}/bin/init.d/jdg %{service_name}
fi

%define jdg_data_dir /var/run/jdg/node-%{node_id}
mkdir -p %{jdg_data_dir}
chown -R %{username}:%{username} %{jdg_data_dir}

%define link_to_configuration /etc/jdg/configuration
if [ ! -L %{link_to_configuration} ]; then
  ln -s %{jdg_home}/standalone/configuration/ %{link_to_configuration}
fi

%clean
exit 0

%description

%files

%doc


%changelog

