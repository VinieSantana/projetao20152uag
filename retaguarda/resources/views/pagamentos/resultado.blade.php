@extends('layouts.principal')

@section('content')

<?php $message=Session::get('message')?>

@if($message=='update')
<div class="alert alert-success alert-dismissible" role="alert">
  <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
  Tabela de preços editada com sucesso
</div>

@endif


{!!Form::open(['url'=>'pagamentos/show', 'class'=>'searchform'])!!}
<legend>Relatório de pagamentos</legend>
<fieldset>
<div class="form-group col-md-2">
  {!!Form::label('Ano')!!}
  
  {!!Form::selectRange('ano',2015, 2011,$request->ano)!!}
  
</div>

<div class="form-group col-md-2">
  {!!Form::label('Mês')!!}
  
  {!!Form::select('mes', array(
    '-%-' => 'Todos',
    '-01-' => 'Janeiro',
    '-02-' => 'Fevereiro',
    '-03-' => 'Março',
    '-04-' => 'Abril',
    '-05-' => 'Maio',
    '-06-' => 'Junho',
    '-07-' => 'Julho',
    '-08-' => 'Agosto',
    '-09-' => 'Setembro',
    '-10-' => 'Outubro',
    '-11-' => 'Novembro',
    '-12-' => 'Dezembro',
),$request->mes)!!}

  <!--{!!Form::selectRange('mes', 1,12)!!}-->
  
</div>

<div class="form-group col-md-2">
  {!!Form::label('Dia')!!}
  
  {!!Form::select('dia', array(
    '% ' => 'Todos',
    '01 ' => '01',
    '02 ' => '02',
    '03 ' => '03',
    '04 ' => '04',
    '05 ' => '05',
    '06 ' => '06',
    '07 ' => '07',
    '08 ' => '08',
    '09 ' => '09',
    '10 ' => '10',
    '11 '  => '11',
    '12 ' => '12',
    '13 '  => '13',
    '14 ' => '14' ,
    '15 '  => '15',
    '16 '  => '16',
    '17 '  => '17',
    '18 '  => '18',
    '19 '  => '19',
    '20 '  => '20',
    '21 '  => '21',
    '22 '  => '22',
    '23 ' => '23' ,
    '24 '  => '24',
    '25 '  => '25',
    '26 '  => '26',
    '27 '  => '27',
    '28 ' => '28',
    '29 '  => '29',
    '30 '  => '30',
    '31 '  => '31',

),$request->dia)!!}
  
  
</div>
<!--<div class="form-group col-md-3">
  {!!Form::label('Resultados por página')!!}
  {!!Form::selectRange('paginas',4, 15, $request->paginas)!!}
</div>-->
<div class="form-group col-md-2">


{!!Form::submit('Buscar', ['class'=>'btn btn-primary'])!!}
</div>
</fieldset>
 {!!Form::close()!!} 

 {!!Form::open(['url'=>'pagamentos/pdf'])!!}

{!!Form::hidden('ano', $request->ano)!!}
{!!Form::hidden('mes', $request->mes)!!}


{!!Form::hidden('dia', $request->dia)!!}


{!!Form::submit('Versão para impressão', ['class'=>'btn btn-primary'])!!}

{!!Form::close()!!} 
 
<br><br>

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
        <td>{!! substr($user->date_payment,8,2)."/".substr($user->date_payment,5,2)."/".substr($user->date_payment,0,4)." - ".substr($user->date_payment,10,9)!!}</td>
        <td>{!!"R$ ".$user->val!!}</td>
        
        
    </tbody>
    @endforeach
    
    
 
 </table>

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
{!! $users->render()!!}



@stop