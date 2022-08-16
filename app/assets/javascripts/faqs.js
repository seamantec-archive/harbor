$(function(){
    $('#faq-accordion').sortable();
    $('#faq-accordion').on('sortstop', function(e, ui){
        if(ui.item.hasClass('panel')) {
            $.post('/faqs/topic_change', {
                topic_id: ui.item.data('id'),
                list_position: $(e.target).children('.panel').index(ui.item) + 1
            }, function(){});
        }
    });

    $('#faq-accordion .list-unstyled').sortable({
        connectWith: '#faq-accordion'
    });
    $('#faq-accordion .list-unstyled').on('sortstop', function(e, ui){
        var parent = ui.item.parent();
        if(parent.hasClass('panel-group')) {
            var index = parent.children().index(ui.item) + 1;
            if(index==parent.children().length) {
                $('#faq-accordion .list-unstyled').sortable('cancel');
            } else {
                var topic = ui.item.next();
                var topic_id = topic.data('id');
                if(topic_id!=ui.item.data('topic-id')) {
                    $.post('/faqs/question_topic_change', {
                        id: ui.item.data('id'),
                        topic_id: ui.item.data('topic-id'),
                        new_topic_id: topic_id
                    }, function(data){
                        if(data.length>0) {
                            topic.find('.list-unstyled').append(ui.item);
                            ui.item.refreshData(data, topic_id);
                        } else {
                            $('#faq-accordion .list-unstyled').sortable('cancel');
                        }
                    }).fail(function(){
                        $('#faq-accordion .list-unstyled').sortable('cancel');
                    });
                } else {
                    $('#faq-accordion .list-unstyled').sortable('cancel');
                }
            }
        } else {
            $.post('/faqs/question_change', {
                id: ui.item.data('id'),
                topic_id: ui.item.data('topic-id'),
                list_position: $(e.target).children('li').index(ui.item) + 1
            }, function(){});
        }
    });
});

jQuery.prototype.refreshData = function(id, topic_id) {
    $(this).data('id', id);
    $(this).data('topic-id', topic_id);
    $(this).find('.edit-question').changeURL(id, topic_id);
    $(this).find('.destroy-question').changeURL(id, topic_id);
}

jQuery.prototype.changeURL = function(id, topic_id) {
    var url = $(this).attr('href').substr(0, $(this).attr('href').indexOf('?') + 1);
    $(this).attr('href', url + 'id=' + id + '&topic_id=' + topic_id);
}
