%define node_id 1
%define node_spec_version 1.0

%define product_version 6.0.1

%define product_name jboss-eap
%define product_home /usr/local/java/%{product_name}-6.0.1

%define username java
%define group java

Name:	    %{product_name}
Version:	%{product_version}
Release:	1%{?dist}
Summary:    Set up instance %{node_id} of JBoss Enterprise Application Platform %{product_version}

Group:      Administration
License:	GPL
URL:        http://access.redhat.com/

Packager:   Romain Pelisse
BuildArch:  noarch

Source0:    %{product_name}-%{product_version}.tgz

Patch0:     jboss-as-standalone.sh.patch
Patch1:     add-node-default-jvm-settings.patch


Requires(pre): java-1.6.0-openjdk

%prep
%setup -q
%patch0 -p1
%patch1 -p1

%pre
mkdir -p %{product_home}
getent group %{group} > /dev/null || groupadd -r %{group}
getent passwd %{username}  > /dev/null || \
    useradd -r -g %{group} -d %{product_home} -s /sbin/nologin \
    -c "Java user account" %{username}

%install
mkdir -p %{buildroot}/%{product_home}
cp -rp %{_builddir}/%{name}-%{version}/* %{buildroot}/%{product_home}

%post

%define eap_conf_folder /etc/%{product_name}
mkdir -p %{eap_conf_folder}
sed -e "s;\(export NODE_ID=\).*$;\1'%{node_id}';g" \
    -e "s;\(export JBOSS_HOME=\).*$;\1'%{product_home}';g" \
    -e "s;\(export JBOSS_USER=\).*$;\1'%{username}';g" \
    %{product_home}/bin/init.d/jboss-as.conf > %{eap_conf_folder}/node-%{node_id}.conf

%define service_name /etc/init.d/%{product_name}-%{node_id}
if [ ! -L %{service_name} ]; then
  ln -s %{product_home}/bin/init.d/jboss-as-standalone.sh %{service_name}
fi

%define product_data_dir /var/run/%{product_name}/node-%{node_id}
mkdir -p %{product_data_dir}
chown -R %{username}:%{username} %{product_data_dir}

%define link_to_configuration %{eap_conf_folder}/configuration
if [ ! -L %{link_to_configuration} ]; then
  ln -s %{product_home}/standalone/configuration/ %{link_to_configuration}
fi

%clean
exit 0

%description

%files
%defattr(-,%{username},%{group})
%{product_home}


%doc


%changelog

