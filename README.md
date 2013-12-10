jdg-rpm-infra overview
=======================

A set of specfile template to generate RPMs for installing JDG libs, and instances. The project is
designed to be checkout in our 'rpmbuilder' folder (where you build your RPMs, which should contains
the usual RPMS, SRPMS, BUILD, BUILDROOT, and so on directories), and from then automate the SPEC
generation - and can also build the RPMs.

This project will help you generate the following RPM:
* *jdg*, which contains all the jars and other files requested to run one instance of JDG
* *node[1-n]*, a package to install one local instance of JDG

Obviously, the number suffixing the node's package, allow you to install several node locally, and
take care of setting up the required parameters for such set up. Hence, at the end of day, all
you'll need to install a local 3 nodes, local, grid will be:

    # yum install -y jdg jdg-node1 jdg-node2 jdg-node3

Once the package is installed, you'll be able to fire up those 3 nodes like that:

    # for node in /etc/init.d/jdg-node*
    # do
    #   service "${node}" start &
    # done

And checks if everything went fine with the following logfiles:

    # tail -f /var/log/jdg/node-*.conf

You can tweak the settings of the grid itself into the /etc/jdg/configuration/clustered.xml, and the
settings of each node in /etc/jdg/node-X.conf.

This project requires to only maintains a *couple* of template files, from which it generates the
required RPM.

Running the project
===================

1. Setting up the 'rpmbuild' infrastructure
-------------------------------------------

Please refer to available 'rpmbuild' documentation and tutorial.

2. Generating the SPEC files from the templates
-----------------------------------------------

The templates files lives in the templates/ directory. To generate proper SPEC files from those
templates, you'll just need to run the following script:

$ ./bin/generate-specs.sh

All values with XXX will be replaced by this script. To change the way the script is updating those
value you'll need to edit the 'jdg.properties' (or 'jon.properties for JON) file.


3. Packaging JDG (and JON) files
--------------------------------

*NOTICE:* if you use Red Hat Satellite, you may have access to package version of JDG and/or JON. If
this is the case, please, disregard this step, and simply modify the jdg and jon spec's template to
depends on those provided packages.

In order for the spec file for JDG (and JON) to packages the file from those product, you'll need to
run set the appropriate environment variable and the following script:

    $ export JDG_REPOSITORY=~/downloads/jboss-datagrid-6.1
    $ ./bin/sync-src

Depending on the system you are building on, you'll most likely also need to modify the source name,
in the script:

    $ export JDG_BUILDROOT='./BUILDROOT/jdg-6.1-0.fc18.x86_64/opt/jboss/jboss-datagrid-6.1'
    $ export JDG_REPOSITORY=~/downloads/jboss-datagrid-6.1
    $ ./bin/sync-src

The same variables must be set for JON. If the variables are not set, the script will just skip
those synchronise.

4. Build RPMs
-------------

Once the two previous script has been ran successfully, you can use the provided commodity script to
build everything:

    $ ./bin/build-rpms.sh

5. Build all
------------

In order to represent the all process implemented by the previous script, a 'build-all.sh' script
have also been provided:

    $ ./bin/build-all.sh

