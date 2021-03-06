
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../../favicon.ico">

    <title>&nbsp;</title>

    <!-- Latest compiled and minified CSS -->
   {!!Html::style('https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css')!!}
   {!!Html::style('assets/css/printable.css')!!}
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>

      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>

    <![endif]-->
  </head>
<body>

  <div class="container">
   
    <h2 align="center"><img src="../assets/img/logo.jpg" width="100" height="60"></h2>
    <h5 align="center">RELATÓRIO DE PAGAMENTOS</h5>
    <br><br>

    <table class="table">
  <thead>
     <th>Total de pagamentos no período:</th>
        <th>Total arrecadado no período:</th>  
      </thead> 
      <tbody>
        <td>{!!$numero!!}</td>
        <td>{!!"R$ ".$total!!}</td>  
      </tbody>

</table>
  <table class="table table-bordered">
    <thead>
      
      <th>Id</th>
      <th>Apelido do usuário</th>
      <th>Data e Hora</th>
      <th>Valor</th>
      
    </thead>
    @foreach($users as $user)
    <tbody>
        <td>{!!$user->id!!}</td>
        <td>{!!$user->nickname!!}</td>
        <td>{!! substr($user->date_payment,8,2)."/".substr($user->date_payment,5,2)."/".substr($user->date_payment,0,4)." - ".substr($user->date_payment,10,9)!!}</td>        <td>{!!"R$ ".$user->val!!}</td>
        
        
    </tbody>
    @endforeach
    
    
 
 </table>



</div>

    {!!Html::script('https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js')!!}
    {!!Html::script('https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js')!!}  

  </body>
</html>
