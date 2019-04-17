import trackball_suite

def test1():
    sourcefile = 'C:\\Users\\Sur lab\\Dropbox (MIT)\\trackball-behavior\\Data\\C13\\laser_analys_FebMar2019_left\\20190220_trackball_0013.mat'
    session = trackball_suite.Session(sourcefile)

    assert session.choice[0] == 1