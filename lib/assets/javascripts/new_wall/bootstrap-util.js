// Copiado do bootstrap sem modificações.


// Retorna uma string com as classes de ícones identificadas.
//
// Dado uma string "classes", encontra todas as classes de ícones nela.
var findIconClasses = function(classes) {
  var iconClasses = [];

  if (classes) {
    classes = classes.split(' ');
    $.each(classes, function(index, value) {
      if (value.indexOf('icon-') !== -1) {
        iconClasses.push(value);
      }
    });
  }

  return iconClasses.join(' ');
};