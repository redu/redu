$(function(){
  $(".form-search-filters-dropdown :radio").change(function() {
    $this = $(this)[0];
    if($this.value === "geral"){
      $(".form-search").attr("action", "/busca")
    }else if($this.value === "ambientes") {
      $(".form-search").attr("action", "/busca/ambientes")
    }else if($this.value === "perfil") {
      $(".form-search").attr("action", "/busca/perfis")
    }
  });
});
