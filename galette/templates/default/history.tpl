{extends file="page.tpl"}

{block name="content"}
    <form action="{path_for name="history_filter"}" method="post" id="filtre" class="ui form">
        <div class="ui segment">
            <div class="four fields">
                <div class="two fields">
                    <div class="field">
                        <label for="start_date_filter">{_T string="since"}</label>
                        <div class="ui calendar" id="contrib-rangestart">
                            <div class="ui input left icon">
                                <i class="calendar icon"></i>
                                <input placeholder="{_T string="yyyy-mm-dd"}" type="text" name="start_date_filter" id="start_date_filter" maxlength="10" size="10" value="{$history->filters->start_date_filter}"/>
                            </div>
                        </div>
                    </div>
                    <div class="field">
                        <label for="end_date_filter">{_T string="until"}</label>
                        <div class="ui calendar" id="contrib-rangeend">
                            <div class="ui input left icon">
                                <i class="calendar icon"></i>
                                <input placeholder="{_T string="yyyy-mm-dd"}" type="text" name="end_date_filter" id="end_date_filter" maxlength="10" size="10" value="{$history->filters->end_date_filter}"/>
                            </div>
                        </div>
                    </div>
                </div>
    {assign var="users" value=$history->getUsersList()}
    {if $users|@count gt 0}
                <div class="field">
                    <label for="user_filter">{_T string="Member"}</label>
                    <select name="user_filter" id="user_filter">
                        <option value="0"{if $history->filters->user_filter eq 0} selected="selected"{/if}>{_T string="Select an user"}</option>
        {foreach from=$users item=$user}
                        <option value="{$user}"{if $history->filters->user_filter === $user} selected="selected"{/if}>{$user}</option>
        {/foreach}
                    </select>
                </div>
    {/if}
    {assign var="actions" value=$history->getActionsList()}
    {if $actions|@count gt 0}
                <div class="field">
                    <label for="action_filter">{_T string="Action"}</label>
                    <select name="action_filter" id="action_filter">
                        <option value="0">{_T string="Select an action"}</option>
        {foreach from=$actions item=$action}
                        <option value="{$action}"{if $history->filters->action_filter eq $action} selected="selected"{/if}>{$action}</option>
        {/foreach}
                    </select>
    {/if}
                </div>
                <div class="flexend center aligned field">
                    <input type="submit" class="ui blue button" value="{_T string="Filter"}"/>
                    <input type="submit" name="clear_filter" class="ui button" value="{_T string="Clear filter"}"/>
                </div>
            </div>
        </div>

        <div class="infoline">
            <div class="ui basic horizontal segments">
                <div class="ui basic fitted segment">
                    <a
                        class="negative ui button"
                        href="{path_for name="flushHistory"}"
                    >
                        <i class="icon trash"></i>
                        {_T string="Flush the logs"}
                    </a>
                    <div class="ui label">{$history->getCount()} {if $history->getCount() != 1}{_T string="entries"}{else}{_T string="entry"}{/if}</div>
                </div>
                <div class="ui basic right aligned fitted segment">
                    <div class="inline field">
                        <label for="nbshow">{_T string="Records per page:"}</label>
                        <select name="nbshow" id="nbshow" class="ui dropdown">
                            {html_options options=$nbshow_options selected=$numrows}
                        </select>
                        <noscript> <span><input type="submit" value="{_T string="Change"}" /></span></noscript>
                    </div>
                </div>
            </div>
        </div>
    </form>

        <table class="listing ui celled table">
            <thead>
                <tr>
                    <th class="small_head">#</th>
                    <th class="left date_row">
                        <a href="{path_for name="history" data=["option" => "order", "value" => "Galette\Filters\HistoryList::ORDERBY_DATE"|constant]}">
                            {_T string="Date"}
                            {if $history->filters->orderby eq constant('Galette\Filters\HistoryList::ORDERBY_DATE')}
                                {if $history->filters->ordered eq constant('Galette\Filters\HistoryList::ORDER_ASC')}
                            <img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt="{_T string="Ascendent"}"/>
                                {else}
                            <img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt="{_T string="Descendant"}"/>
                                {/if}
                            {/if}
                        </a>
                    </th>
                    <th class="left date_row">
                        <a href="{path_for name="history" data=["option" => "order", "value" => "Galette\Filters\HistoryList::ORDERBY_IP"|constant]}">
                            {_T string="IP"}
                            {if $history->filters->orderby eq constant('Galette\Filters\HistoryList::ORDERBY_IP')}
                                {if $history->filters->ordered eq constant('Galette\Filters\HistoryList::ORDER_ASC')}
                            <img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt="{_T string="Ascendent"}"/>
                                {else}
                            <img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt="{_T string="Descendant"}"/>
                                {/if}
                            {/if}
                        </a>
                    </th>
                    <th class="left date_row">
                        <a href="{path_for name="history" data=["option" => "order", "value" => "Galette\Filters\HistoryList::ORDERBY_USER"|constant]}">
                            {_T string="User"}
                            {if $history->filters->orderby eq constant('Galette\Filters\HistoryList::ORDERBY_USER')}
                                {if $history->filters->ordered eq constant('Galette\Filters\HistoryList::ORDER_ASC')}
                            <img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt="{_T string="Ascendent"}"/>
                                {else}
                            <img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt="{_T string="Descendant"}"/>
                                {/if}
                            {/if}
                        </a>
                    </th>
                    <th class="left username_row">
                        <a href="{path_for name="history" data=["option" => "order", "value" => "Galette\Filters\HistoryList::ORDERBY_ACTION"|constant]}">
                            {_T string="Action"}
                            {if $history->filters->orderby eq constant('Galette\Filters\HistoryList::ORDERBY_ACTION')}
                                {if $history->filters->ordered eq constant('Galette\Filters\HistoryList::ORDER_ASC')}
                            <img src="{base_url}/{$template_subdir}images/down.png" width="10" height="6" alt="{_T string="Ascendent"}"/>
                                {else}
                            <img src="{base_url}/{$template_subdir}images/up.png" width="10" height="6" alt="{_T string="Descendant"}"/>
                                {/if}
                            {/if}
                        </a>
                    </th>
                    <th class="left">
                        {_T string="Description"}
                    </th>
                </tr>
            </thead>
            <tbody>
{if $logs|@count == 0}
                <tr><td colspan="6" class="emptylist">{_T string="No log found"}</td></tr>
{else}
    {foreach from=$logs item=log name=eachlog}
                <tr class="{if $smarty.foreach.eachlog.iteration % 2 eq 0}even{else}odd{/if}">
                    <td data-scope="row">
                        {$smarty.foreach.eachlog.iteration}
                        <span class="row-title">
                            {_T string="History entry %id" pattern="/%id/" replace=$smarty.foreach.eachlog.iteration}
                        </span>
                    </td>
                    <td class="nowrap" data-title="{_T string="Date"}">{$log.date_log|date_format:"%a %d/%m/%Y - %R"}</td>
                    <td class="nowrap" data-title="{_T string="IP"}">{$log.ip_log}</td>
                    <td data-title="{_T string="User"}">{$log.adh_log}</td>
                    <td data-title="{_T string="Action"}">{$log.action_log}</td>
                    <td data-title="{_T string="Description"}">
                        {$log.text_log}
        {if $log.sql_log}
                        <span class="sql_log">{$log.sql_log|escape:"htmlall"}</span>
        {/if}
                    </td>
                </tr>
    {foreachelse}
                <tr><td colspan="6" class="emptylist">{_T string="logs are empty"}</td></tr>
    {/foreach}
{/if}
            </tbody>
        </table>
{if $logs|@count != 0}
        <div class="ui basic center aligned fitted segment">
            <div class="ui pagination menu">
                <div class="header item">
                    {_T string="Pages:"}
                </div>
                {$pagination}
            </div>
        </div>
{/if}
{/block}

{block name="javascripts"}
        <script type="text/javascript">
            $('#nbshow').change(function() {
                this.form.submit();
            });

            $(function() {
                {include file="js_removal.tpl"}
                var _elt = $('<img src="{base_url}/{$template_subdir}images/info.png" class="qryhide" alt="" title="{_T string="Show associated query"}"/>');
                $('.sql_log').hide().parent().prepend(_elt);
                $('.qryhide').click(function() {
                    $(this).next('.sql_log').show();
                });
            });

            $('#start_date_filter, #end_date_filter').datepicker({
                changeMonth: true,
                changeYear: true,
                showOn: 'button',
                buttonText: '<i class="far fa-calendar-alt"></i> <span class="sr-only">{_T string="Select a date" escape="js"}</span>'
            });
        </script>
{/block}
