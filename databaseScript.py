# -*- coding: utf-8 -*-
"""
Created on Thu Mar 09 13:44:53 2017

@author: Sriva
"""

import blaze as bz
#csv_path = 'C:/Users/Sriva/Desktop/George Mason/Spring 2017/DAEN 690/database/GNDTNDR.csv'
#bz.odo(csv_path, 'sqlite:///data.db::data')
csv_path = 'C:/Users/Sriva/Desktop/George Mason/Spring 2017/DAEN 690/database/GNDITEM.csv'
bz.odo(csv_path, 'sqlite:///data.db::gnditem')