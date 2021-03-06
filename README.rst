********************************************************************************
DFTB+XT: open software package for quantum nanoscale modeling
********************************************************************************

DFTB+XT is DFTB+ eXTended version for model and atomistic quantum 
transport at nanoscale, many-body nonequilibrium phenomena, material & device modeling.

DFTB+XT is the core package of TraNaS OpenSuite, tranas.org/opensuite.

The project is hosted on `github <http://github.com/tranas-open/dftbXT>`_.

********************************************************************************
DFTB+: general package for performing fast atomistic calculations
********************************************************************************

|lgpl badge|

DFTB+ is a software package for carrying out fast quantum mechanical atomistic
calculations based on the Density Functional Tight Binding method. The most
recent features are described in the (open access) `DFTB+ paper
<https://doi.org/10.1063/1.5143190>`_.

DFTB+ can be either used as a standalone program or integrated into other
software packages as a library.


Installation
============

Building from source
--------------------

**Note:** This section describes the building with default settings (offering
only a subset of all possible features in DFTB+) in a typical Linux
environment. For more detailed information on the build customization and the
build process, consult the **detailed building instructions** in `INSTALL.rst
<INSTALL.rst>`_.

The source code of the last stable release can be downloaded from the 
`TraNaS OpenSuite homepage <http://tranas.org/opensuite>`_.

Alternatively you can clone the `public git repository
<https://github.com/tranas-open/dftbXT>`_. 

You need CMake (>= 3.16) to build DFTB+. If your environment offers no CMake or
an only an older one, you can easily install the latest CMake via Python's
``pip`` command::

  pip install cmake

Start CMake by passing your compilers as environment variables (``FC`` and
``CC``), and the location where the code should be installed and the build
directory (``_build``) and als options::

  FC=gfortran CC=gcc cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/dftb+ -B _build .

If the configuration was successful, start the build with::

  cmake --build _build -- -j

After successful build, you should test the code. First download the SK-files
needed for the test ::

  ./utils/get_opt_externals slakos

and then run the tests with ::

  pushd _build; ctest -j; popd

If the tests were successful, install the package with ::

  cmake --install _build

For further details see the `detailed building instructions <INSTALL.rst>`_.


Parameterisations
=================

In order to carry out calculations with DFTB+, you need according
parameterisations (a.k.a. Slater-Koster files). You can download them from
`dftb.org <https://dftb.org>`_.


Documentation DFTB+XT
=====================

  <http://tranas.org/opensuite/documentation.html>`_

Documentation DFTB+
===================

Consult following resources for documentation:

* `Step-by-step instructions with selected examples (DFTB+ Recipes)
  <http://dftbplus-recipes.readthedocs.io/>`_

* `Reference manual describing all features (DFTB+ Manual)
  <http://www.dftbplus.org/fileadmin/DFTBPLUS/public/dftbplus/latest/manual.pdf>`_


Citing
======

When publishing results obtained with DFTB+XT, please cite as: 
DFTB+XT software package from TraNaS OpenSuite [1],
partially based on the DFTB+ software package [2,3].

[1] TraNaS OpenSuite, tranas.org/opensuite
[2] B. Hourahine et al., J. Chem. Phys. 152, 124101 (2020)
[3] A. Pecchia et al., New Journal of Physics 10, 065022 (2008) 

* Reference publications of the Slater-Koster parameterization sets you
  used. (See `dftb.org <https://dftb.org>`_ for the references.)

* Methodological papers relevant to your calculations (e.g. excited states,
  electron-transport, third order DFTB etc.). Those references can be found in
  the `DFTB+ manual
  <http://www.dftbplus.org/fileadmin/DFTBPLUS/public/dftbplus/latest/manual.pdf>`_.


Contributing
============

New features, bug fixes, documentation, tutorial examples and code testing is
welcome in the DFTB+ developer community!

The project is `hosted on github <http://github.com/dftbplus/>`_.
Please check `CONTRIBUTING.rst <CONTRIBUTING.rst>`_ and the `DFTB+ developers
guide <https://dftbplus-develguide.readthedocs.io/>`_ for guide lines.

We are looking forward to your pull request!


License
=======

DFTB+ is released under the GNU Lesser General Public License. See the included
`LICENSE <LICENSE>`_ file for the detailed licensing conditions.



.. |DFTB+ logo| image:: https://www.dftbplus.org/fileadmin/DFTBPLUS/images/DFTB-Plus-Icon_06_f_150x150.png
    :alt: DFTB+ website
    :scale: 100%
    :target: https://dftbplus.org/

.. |lgpl badge| image:: http://www.dftbplus.org/fileadmin/DFTBPLUS/images/license-GNU-LGPLv3-blue.svg
    :alt: LGPL v3.0
    :scale: 100%
    :target: https://opensource.org/licenses/LGPL-3.0
