### Ordner mit Datenanalyseskripten
* RMSD-Berechnung? War in tcl, Datenplot in Python. Nein, weil fehlende Möglichkeit zu testen.
* Dihedral angles in VMD, Histogramm in Python, PMF in Python, Umrechnung in kcal/mol
* Number of water molecules hydrogen bonding to phosphate
* Radial distribution function (in VMD), plot in Python
* Dipolskript plus zugehöriges Histogramm. Histogramm musste sehr klein gemacht werden (Übergang zum Integral), um die Gaußverteilung zu sehen
* Dipol moment values feeded into normalized correlate function from scipy.signal to see whether trajectory converged
* Linear fit of first 1000 values of autocorrelation function for first hydration shell and bulk water
* linear fit instead of exponential as exponential fit relies heavily on initial parameters
* Linearisierung mit log scale auf y Achse nicht machbar, weil die starken Fluktuatione zu viele Fehler reinreißen
* 
