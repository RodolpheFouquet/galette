<?php

/* vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4: */

/**
 * Export
 *
 * Permet l'export de données au format CSV
 *
 * PHP version 5
 *
 * Copyright © 2009-2013 The Galette Team
 *
 * This file is part of Galette (http://galette.tuxfamily.org).
 *
 * Galette is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Galette is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Galette. If not, see <http://www.gnu.org/licenses/>.
 *
 * @category  Main
 * @package   Galette
 *
 * @author    Johan Cwiklinski <johan@x-tnd.be>
 * @copyright 2009-2013 The Galette Team
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GPL License 3.0 or (at your option) any later version
 * @version   SVN: $Id: export.php 535 2009-02-11 07:23:06Z trashy $
 * @link      http://galette.tuxfamily.org
 * @since     Available since 0.7dev - 2009-02-16
 */

require_once 'includes/galette.inc.php';

if ( !$login->isLogged() ) {
    header('location: index.php');
    die();
}
if ( !$login->isAdmin() && !$login->isStaff() ) {
    header('location: voir_adherent.php');
    die();
}

use Galette\IO\Csv;
use Galette\Entity\Adherent;
use Galette\Entity\FieldsConfig;
use Galette\Repository\Members;

$csv = new Csv();

$written = array();

$tables_list = $zdb->getTables();

if ( isset($_GET['sup']) ) {
    $res = $csv->removeExport($_GET['sup']);
    if ( $res === true ) {
        $success_detected[] = str_replace(
            '%export',
            $_GET['sup'],
            _T("'%export' file has been removed from disk.")
        );
    } else {
        $error_detected[] = str_replace(
            '%export',
            $_GET['sup'],
            _T("Cannot remove '%export' from disk :/")
        );
    }
}

if ( isset( $_POST['export_tables'] ) && $_POST['export_tables'] != '' ) {
    foreach ( $_POST['export_tables'] as $table) {
        $select = new \Zend_Db_Select($zdb->db);
        $select->from($table);
        $result = $select->query()->fetchAll(Zend_Db::FETCH_ASSOC);

        $filename = $table . '_full.csv';
        $filepath = Csv::DEFAULT_DIRECTORY . $filename;
        $fp = fopen($filepath, 'w');
        if ( $fp ) {
            $res = $csv->export(
                $result,
                Csv::DEFAULT_SEPARATOR,
                Csv::DEFAULT_QUOTE,
                true,
                $fp
            );
            fclose($fp);
            $written[] = array(
                'name' => $filename,
                'file' => $filepath
            );
        }
    }
}

if ( isset( $_POST['export_parameted'] ) && $_POST['export_parameted'] != '' ) {
    foreach ( $_POST['export_parameted'] as $p) {
        $res = $csv->runParametedExport($p);
        $pn = $csv->getParamedtedExportName($p);
        switch ( $res ) {
        case Csv::FILE_NOT_WRITABLE:
            $error_detected[] = str_replace(
                '%export',
                $pn,
                _T("Export file could not be write on disk for '%export'. Make sure web server can write in the exports directory.")
            );
            break;
        case Csv::DB_ERROR:
            $error_detected[] = str_replace(
                '%export',
                $pn,
                _T("An error occured running parameted export '%export'.")
            );
            break;
        case false:
            $error_detected[] = str_replace(
                '%export',
                $pn,
                _T("An error occured running parameted export '%export'. Please check the logs.")
            );
            break;
        default:
            //no error, file has been writted to disk
            $written[] = array(
                'name' => $pn,
                'file' => $res
            );
            break;
        }
    }
}

if ( isset($_GET['current_filter']) ) {

    if ( isset($session['filters']['members'])
        && !isset($_POST['mailing'])
        && !isset($_POST['mailing_new'])
    ) {
        //CAUTION: this one may be simple or advanced, display must change
        $filters = unserialize($session['filters']['members']);
    } else {
        $filters = new MembersList();
    }

    /*$fields_list = Adherent::getDbFields();
    //fields we do not want to export.
    unset($fields_list['mdp_adh']);*/

    $fc = new FieldsConfig(Adherent::TABLE, null);
    // fields visibility
    $visibles = $fc->getVisibilities();
    $fields = array();
    $headers = array();
    include_once 'galette/includes/members_fields.php';
    foreach ( $members_fields as $k=>$f ) {
        if ( $k !== 'mdp_adh' ) {
            if ( $visibles[$k] === FieldsConfig::VISIBLE ) {
                $fields[] = $k;
                $labels[] = $f['label'];
            } else if ( ($login->isAdmin()
                || $login->isStaff()
                || $login->isSuperAdmin())
                && $visibles[$k] === FieldsConfig::ADMIN
            ) {
                $fields[] = $k;
                $labels[] = $f['label'];
            }
        }
    }

    $members = new Members($filters);
    $members_list = $members->getMembersList(false, $fields);

    $filename = 'filtered_memberslist.csv';
    $filepath = Csv::DEFAULT_DIRECTORY . $filename;
    $fp = fopen($filepath, 'w');
    if ( $fp ) {
        $res = $csv->export(
            $members_list,
            Csv::DEFAULT_SEPARATOR,
            Csv::DEFAULT_QUOTE,
            $labels,
            $fp
        );
        fclose($fp);
        $written[] = array(
            'name' => $filename,
            'file' => $filepath
        );
    }
}

$parameted = $csv->getParametedExports();
$existing = Csv::getExistingExports();

$tpl->assign('page_title', _T("CVS database Export"));
$tpl->assign('tables_list', $tables_list);
$tpl->assign('written', $written);
$tpl->assign('existing', $existing);
$tpl->assign('success_detected', $success_detected);
$tpl->assign('error_detected', $error_detected);
$tpl->assign('parameted', $parameted);
$content = $tpl->fetch('export.tpl');
$tpl->assign('content', $content);

$tpl->display('page.tpl');
